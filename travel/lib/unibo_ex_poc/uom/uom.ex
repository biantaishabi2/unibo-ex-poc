# Workflow: uom_maintain_flow — 计量单位维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Uom.Uom do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Uom,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "计量单位，以 reference 单位为中心，通过 factor 实现同分类内数量和价格换算"
  end

  postgres do
    table "uom_uoms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :uom_uom

    queries do
      get :get_uom_uom, :read
      list :list_uom_uoms, :read
      get :get_compute_quantity_uom_uom, :compute_quantity
      list :list_compute_quantity_uom_uoms, :compute_quantity
      get :get_compute_price_uom_uom, :compute_price
      list :list_compute_price_uom_uoms, :compute_price
    end

    mutations do
      create :create_uom_uom, :create
      update :update_uom_uom, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "单位名称（如：千克、克、磅）"
    end
    attribute :factor, :float do
      allow_nil? false
      default 1.0
      public? true
      description "换算比率（相对于参考单位，不能为 0）"
    end
    attribute :rounding, :float do
      default 0.01
      public? true
      description "舍入精度（必须为正数）"
    end
    attribute :uom_type, :atom do
      allow_nil? false
      constraints one_of: [:bigger, :reference, :smaller]
      default :reference
      public? true
      description "单位类型（bigger=比参考单位大, reference=参考单位, smaller=比参考单位小）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :factor_inv, :float, expr((1 / factor))
    calculate :ratio, :float, expr(%{condition: %{op: "eq", args: [%{op: "ref", args: ["uom_type"]}, "reference"]}, value: 1})
  end

  relationships do
    belongs_to :category, UniboExPoc.Uom.UomCategory do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboExPoc.Uom.UomTranslation, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :factor, :rounding, :uom_type, :active]
      argument :category_id, :uuid, allow_nil?: false
      change manage_relationship(:category_id, :category, type: :append, on_lookup: :relate)
      validate attribute_does_not_equal(:factor, 0)
      validate compare(:factor, equal_to: 1)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :factor, :rounding, :uom_type, :active]
      # skipped: validate compare :factor (incompatible with bulk update atomic path)
      # skipped: validate compare :factor (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    read :compute_quantity do
      description "数量换算：将 qty 从当前单位换算到目标单位（同分类内）。公式：amount = qty / self.factor * to_unit.factor"
      argument :qty, :decimal, allow_nil?: false
      argument :to_unit_id, :uuid, allow_nil?: false
      argument :round, :boolean
    end
    read :compute_price do
      description "价格换算：将 price 从当前单位换算到目标单位（方向与数量换算相反）。公式：amount = price * self.factor / to_unit.factor"
      argument :price, :decimal, allow_nil?: false
      argument :to_unit_id, :uuid, allow_nil?: false
    end
  end

  validations do
    validate compare(:rounding, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  @uom_runtime_table "uom_uoms"

  # UoM 运行时换算辅助函数（issue #209）

  @doc """
  UoM 数量换算：target_qty = source_qty * (source_factor / target_factor)

  返回:
  - {:ok, %Decimal{}}
  - {:error, reason}
  """
  def convert_quantity(source_uom, target_uom, qty, opts \\ []) do
    with :ok <- ensure_same_uom_category(source_uom, target_uom),
         {:ok, source_factor} <- decimal_field(source_uom, :factor),
         {:ok, target_factor} <- decimal_field(target_uom, :factor),
         :ok <- ensure_positive_factor(source_factor),
         :ok <- ensure_positive_factor(target_factor),
         {:ok, qty_decimal} <- to_decimal_value(qty) do
      result =
        qty_decimal
        |> Decimal.mult(source_factor)
        |> Decimal.div(target_factor)

      {:ok, maybe_round_quantity(result, target_uom, opts)}
    end
  end

  @doc """
  按单位 ID 执行数量换算（会加载 source/target 单位）。
  """
  def convert_quantity_by_id(source_uom_id, to_unit_id, qty, opts \\ []) do
    with {:ok, source_uom} <- load_uom_by_id(source_uom_id),
         {:ok, target_uom} <- load_uom_by_id(to_unit_id) do
      convert_quantity(source_uom, target_uom, qty, opts)
    end
  end

  @doc """
  UoM 价格换算：target_price = source_price * (target_factor / source_factor)

  返回:
  - {:ok, %Decimal{}}
  - {:error, reason}
  """
  def convert_price(source_uom, target_uom, price, opts \\ []) do
    with :ok <- ensure_same_uom_category(source_uom, target_uom),
         {:ok, source_factor} <- decimal_field(source_uom, :factor),
         {:ok, target_factor} <- decimal_field(target_uom, :factor),
         :ok <- ensure_positive_factor(source_factor),
         :ok <- ensure_positive_factor(target_factor),
         {:ok, price_decimal} <- to_decimal_value(price) do
      result =
        price_decimal
        |> Decimal.mult(target_factor)
        |> Decimal.div(source_factor)

      {:ok, maybe_round_price(result, target_uom, opts)}
    end
  end

  @doc """
  按单位 ID 执行价格换算（会加载 source/target 单位）。
  """
  def convert_price_by_id(source_uom_id, to_unit_id, price, opts \\ []) do
    with {:ok, source_uom} <- load_uom_by_id(source_uom_id),
         {:ok, target_uom} <- load_uom_by_id(to_unit_id) do
      convert_price(source_uom, target_uom, price, opts)
    end
  end

  defp ensure_same_uom_category(source_uom, target_uom) do
    source_category = uom_category_id(source_uom)
    target_category = uom_category_id(target_uom)

    cond do
      is_nil(source_category) or is_nil(target_category) ->
        {:error, "单位缺少分类信息"}

      source_category != target_category ->
        {:error, "不兼容的单位类别"}

      true ->
        :ok
    end
  end

  defp uom_category_id(uom) do
    Map.get(uom, :category_id) ||
      Map.get(uom, "category_id") ||
      get_in(uom, [:category, :id]) ||
      get_in(uom, ["category", "id"])
  end

  defp maybe_round_quantity(value, target_uom, opts) do
    if Keyword.get(opts, :round, true) do
      round_by_uom(value, target_uom)
    else
      value
    end
  end

  defp maybe_round_price(value, target_uom, opts) do
    if Keyword.get(opts, :round, false) do
      round_by_uom(value, target_uom)
    else
      value
    end
  end

  defp round_by_uom(value, target_uom) do
    case decimal_field(target_uom, :rounding) do
      {:ok, rounding} ->
        if Decimal.cmp(rounding, Decimal.new("0")) == :gt do
          value
          |> Decimal.div(rounding)
          |> Decimal.round(0)
          |> Decimal.mult(rounding)
        else
          value
        end

      {:error, _reason} ->
        value
    end
  end

  defp decimal_field(data, field) do
    value = Map.get(data, field) || Map.get(data, Atom.to_string(field))

    if is_nil(value) do
      {:error, "缺少字段: #{field}"}
    else
      to_decimal_value(value)
    end
  end

  defp ensure_positive_factor(factor) do
    if Decimal.cmp(factor, Decimal.new("0")) == :gt do
      :ok
    else
      {:error, "factor 必须大于 0"}
    end
  end

  defp to_decimal_value(value) when is_integer(value), do: {:ok, Decimal.new(value)}
  defp to_decimal_value(value) when is_float(value), do: {:ok, Decimal.from_float(value)}
  defp to_decimal_value(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, ""} -> {:ok, decimal}
      _ -> {:error, "无法解析数值"}
    end
  end
  defp to_decimal_value(%Decimal{} = value), do: {:ok, value}
  defp to_decimal_value(_value), do: {:error, "不支持的数值类型"}

  defp load_uom_by_id(uom_id) do
    with {:ok, encoded_uom_id} <- normalize_uuid_param(uom_id) do
      repo = AshPostgres.DataLayer.Info.repo(__MODULE__)
      sql =
        "SELECT id, category_id, factor, rounding FROM " <>
          quote_ident(@uom_runtime_table) <>
          " WHERE id = $1::uuid"

      case Ecto.Adapters.SQL.query(repo, sql, [encoded_uom_id]) do
        {:ok, %{rows: [[id, category_id, factor, rounding]]}} ->
          {:ok, %{id: id, category_id: category_id, factor: factor, rounding: rounding}}

        {:ok, %{rows: []}} ->
          {:error, "单位不存在"}

        {:error, reason} ->
          {:error, "加载单位失败: #{inspect(reason)}"}
      end
    end
  end

  defp normalize_uuid_param(uom_id) when is_binary(uom_id) and byte_size(uom_id) == 16 do
    {:ok, uom_id}
  end

  defp normalize_uuid_param(uom_id) do
    case Ecto.UUID.dump(uom_id) do
      {:ok, dumped} -> {:ok, dumped}
      :error -> {:error, "无效的单位ID"}
    end
  end

  defp quote_ident(name) do
    "\"" <> String.replace(name, "\"", "\"\"") <> "\""
  end
end
