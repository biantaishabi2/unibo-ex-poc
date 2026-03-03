defmodule UniboV4.BDD.DataFactory do
  @moduledoc false

  alias UniboV4.BDD.AshIntrospector

  @doc """
  按属性类型生成合法的属性值 map。
  包含 action accept 列表中的属性 + action arguments。
  """
  def build_attrs(resource, action_name) when is_atom(action_name) do
    action = AshIntrospector.find_action(resource, action_name)
    if is_nil(action), do: raise("Action #{action_name} not found on #{inspect(resource)}")

    accepted = action.accept || []
    all_attrs = Ash.Resource.Info.attributes(resource)

    # 构建 accepted 属性的值
    attr_map =
      accepted
      |> Enum.reduce(%{}, fn attr_name, acc ->
        case Enum.find(all_attrs, &(&1.name == attr_name)) do
          nil -> acc
          attr -> Map.put(acc, attr_name, generate_value(attr))
        end
      end)

    # 构建 action arguments 的值
    arg_map = build_argument_values(action)

    Map.merge(attr_map, arg_map)
  end

  @doc """
  返回空 map，用于触发 required 校验失败。
  """
  def build_invalid_attrs(_resource, _action_name) do
    %{}
  end

  @doc """
  创建一条记录，自动处理 belongs_to 依赖和 actor。
  opts:
    - :actor — 操作者
    - :overrides — 覆盖属性值
    - :visited — 已访问资源集合（防循环）
  """
  def create_record!(resource, action_name, opts \\ []) do
    actor = Keyword.get(opts, :actor, nil)
    overrides = Keyword.get(opts, :overrides, %{})
    visited = Keyword.get(opts, :visited, MapSet.new())

    action = AshIntrospector.find_action(resource, action_name)

    if is_nil(action) do
      raise "Action #{action_name} not found on #{inspect(resource)}"
    end

    # 如果需要 actor，自动创建一个
    actor = actor || maybe_create_actor(resource, action, visited)

    # 处理 belongs_to 依赖
    dep_attrs = ensure_dependencies!(resource, action_name, visited)

    # 生成属性值
    attrs =
      build_attrs(resource, action_name)
      |> Map.merge(dep_attrs)
      |> Map.merge(overrides)

    # 执行创建
    domain = Ash.Resource.Info.domain(resource)

    case Ash.create(resource, attrs, action: action_name, domain: domain, actor: actor) do
      {:ok, record} -> record
      {:error, error} -> raise "Failed to create #{inspect(resource)}: #{inspect(error)}"
    end
  end

  @doc """
  递归创建 belongs_to 依赖，返回依赖的外键属性 map。
  使用 visited set 防止循环依赖。
  """
  def ensure_dependencies!(resource, action_name, visited \\ MapSet.new()) do
    if MapSet.member?(visited, resource) do
      %{}
    else
      visited = MapSet.put(visited, resource)
      action = AshIntrospector.find_action(resource, action_name)
      accepted = if action, do: action.accept || [], else: []

      resource
      |> AshIntrospector.belongs_to_relationships()
      |> Enum.reduce(%{}, fn rel, acc ->
        fk_attr = rel.source_attribute

        # 只处理 action 接受的外键属性，或者非可空的关系
        should_create = fk_attr in accepted or not rel.allow_nil?

        if should_create and Code.ensure_loaded?(rel.destination) do
          try do
            dest_resource = rel.destination
            create_action = find_create_action(dest_resource)

            if create_action do
              dep_record =
                create_record!(dest_resource, create_action.name,
                  visited: visited
                )

              Map.put(acc, fk_attr, Map.get(dep_record, :id))
            else
              acc
            end
          rescue
            _ -> acc
          end
        else
          acc
        end
      end)
    end
  end

  # ============================================================
  # 内部辅助
  # ============================================================

  # 构建 action argument 值
  defp build_argument_values(action) do
    (action.arguments || [])
    |> Enum.reduce(%{}, fn arg, acc ->
      value = generate_argument_value(arg)
      Map.put(acc, arg.name, value)
    end)
  end

  # 为 action argument 生成值
  defp generate_argument_value(arg) do
    constraints = arg.constraints || []

    # 优先处理 one_of 约束
    case Keyword.get(constraints, :one_of) do
      [first | _] ->
        first

      _ ->
        type_name = ash_type_name(arg.type)

        case type_name do
          {:array, _inner} -> []
          :string -> "test_#{random_hex(4)}"
          :integer -> 1
          :decimal -> Decimal.new("100.00")
          :float -> 100.0
          :boolean -> true
          :atom -> :default
          :uuid -> Ash.UUID.generate()
          :map -> %{}
          :date -> Date.utc_today()
          :utc_datetime -> DateTime.utc_now() |> DateTime.truncate(:second)
          :utc_datetime_usec -> DateTime.utc_now()
          :naive_datetime -> NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          _ -> "test_#{random_hex(4)}"
        end
    end
  end

  # 如果 action 使用 relate_actor，创建一个 actor
  defp maybe_create_actor(resource, action, visited) do
    actor_rel = find_actor_relationship(resource, action)

    if actor_rel do
      dest = actor_rel.destination

      if Code.ensure_loaded?(dest) and not MapSet.member?(visited, dest) do
        try do
          create_action = find_create_action(dest)

          if create_action do
            create_record!(dest, create_action.name,
              visited: MapSet.put(visited, resource)
            )
          end
        rescue
          _ -> nil
        end
      end
    end
  end

  # 从 action 的 relate_actor change 中精确找到 actor 关系
  defp find_actor_relationship(resource, action) do
    relate_actor_change =
      Enum.find(action.changes, fn
        %{change: {Ash.Resource.Change.RelateActor, _}} -> true
        _ -> false
      end)

    case relate_actor_change do
      %{change: {Ash.Resource.Change.RelateActor, opts}} ->
        rel_name = Keyword.get(opts, :relationship)
        Enum.find(Ash.Resource.Info.relationships(resource), &(&1.name == rel_name))

      _ ->
        nil
    end
  end

  # 为属性生成合法值
  defp generate_value(attr) do
    if attr.default do
      case attr.default do
        fun when is_function(fun, 0) -> fun.()
        val -> val
      end
    else
      generate_by_type(attr)
    end
  end

  # 按属性类型生成值
  defp generate_by_type(attr) do
    constraints = attr.constraints || []

    case Keyword.get(constraints, :one_of) do
      [first | _] ->
        first

      _ ->
        generate_by_ash_type(attr.type, attr.name, constraints)
    end
  end

  # 按 Ash 类型生成测试值
  defp generate_by_ash_type(type, name, constraints) do
    type_name = ash_type_name(type)

    case type_name do
      :string ->
        max_len = Keyword.get(constraints, :max_length, 50)
        prefix = name |> to_string() |> String.slice(0, 8)
        "#{prefix}_#{random_hex(6)}" |> String.slice(0, max_len)

      :ci_string ->
        prefix = name |> to_string() |> String.slice(0, 8)
        Ash.CiString.new("#{prefix}_#{random_hex(6)}")

      :integer ->
        Enum.random(1..1000)

      :decimal ->
        Decimal.new("100.00")

      :float ->
        100.0

      :boolean ->
        true

      :atom ->
        :default

      :date ->
        Date.utc_today()

      :utc_datetime ->
        DateTime.utc_now() |> DateTime.truncate(:second)

      :utc_datetime_usec ->
        DateTime.utc_now()

      :naive_datetime ->
        NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      :uuid ->
        Ash.UUID.generate()

      :map ->
        %{}

      :term ->
        %{}

      {:array, _} ->
        []

      _ ->
        "test_#{random_hex(4)}"
    end
  end

  # 解析 Ash 类型名称
  defp ash_type_name(type) when is_atom(type) do
    cond do
      type == Ash.Type.String -> :string
      type == Ash.Type.CiString -> :ci_string
      type == Ash.Type.Integer -> :integer
      type == Ash.Type.Decimal -> :decimal
      type == Ash.Type.Float -> :float
      type == Ash.Type.Boolean -> :boolean
      type == Ash.Type.Atom -> :atom
      type == Ash.Type.Date -> :date
      type == Ash.Type.UtcDatetime -> :utc_datetime
      type == Ash.Type.UtcDatetimeUsec -> :utc_datetime_usec
      type == Ash.Type.NaiveDatetime -> :naive_datetime
      type == Ash.Type.UUID -> :uuid
      type == Ash.Type.Map -> :map
      type == Ash.Type.Term -> :term
      type in [:string, :integer, :decimal, :float, :boolean, :atom, :date,
               :utc_datetime, :utc_datetime_usec, :naive_datetime, :uuid,
               :map, :term, :ci_string] -> type
      true -> :unknown
    end
  end

  defp ash_type_name({:array, inner}), do: {:array, ash_type_name(inner)}
  defp ash_type_name(_), do: :unknown

  # 查找 resource 的 create action（优先 primary）
  defp find_create_action(resource) do
    actions = Ash.Resource.Info.actions(resource)

    Enum.find(actions, fn a -> a.type == :create and a.primary? end) ||
      Enum.find(actions, fn a -> a.type == :create end)
  end

  defp random_hex(bytes) do
    :crypto.strong_rand_bytes(bytes) |> Base.encode16(case: :lower)
  end
end
