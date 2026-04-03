defmodule UniboExPoc.Organization.AccessControl do
  @moduledoc """
  organization/core 权限聚合辅助模块。

  提供：
  - actor 角色聚合
  - 功能权限并集聚合
  - 数据权限最大范围计算
  - 数据权限范围映射到 org_scope
  - 面向 #1177 的 ABAC 上下文补全接口
  """

  import Ash.Expr
  require Ash.Query
  alias Ash.Query
  alias UniboExPoc.Organization.OrgScope
  alias UniboExPoc.Organization.Role
  alias UniboExPoc.Organization.RoleAssignment
  alias UniboExPoc.Organization.PermissionNode
  alias UniboExPoc.Organization.RolePermissionGrant
  alias UniboExPoc.Organization.RoleDataScopeGrant

  @scope_rank %{self: 0, department: 1, department_and_children: 2, company: 3, group: 4}

  @doc """
  返回 actor 当前有效角色编码列表。
  """
  @spec role_codes(map() | struct(), module()) :: [String.t()]
  def role_codes(actor, repo \\ UniboExPoc.Repo) do
    actor
    |> active_roles(repo)
    |> Enum.map(& &1.code)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  返回 actor 当前功能权限 key 并集。
  """
  @spec permission_keys(map() | struct(), module()) :: [String.t()]
  def permission_keys(actor, repo \\ UniboExPoc.Repo) do
    actor
    |> active_roles(repo)
    |> Enum.map(& &1.id)
    |> fetch_permission_keys(repo)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  返回 actor 当前最大数据权限范围。
  """
  @spec data_scope(map() | struct(), module()) :: atom()
  def data_scope(actor, repo \\ UniboExPoc.Repo) do
    actor
    |> active_roles(repo)
    |> Enum.map(& &1.id)
    |> fetch_scope_levels(repo)
    |> max_scope_level()
  end

  @doc """
  将数据权限范围映射为可访问的 party_id 集合。

  当前最小映射：
  - self -> actor.party_id
  - 其他更大范围 -> org_scope 递归展开结果
  """
  @spec scope_party_ids(map() | struct(), module()) :: [String.t()]
  def scope_party_ids(actor, repo \\ UniboExPoc.Repo) do
    case {actor_party_id(actor), data_scope(actor, repo)} do
      {nil, _} ->
        []

      {party_id, :self} ->
        OrgScope.resolve_simple(party_id)

      {party_id, _} ->
        OrgScope.resolve(party_id, repo)
    end
  end

  @doc """
  返回统一权限上下文，供 GraphQL/BFF/runtime 消费。
  """
  @spec permission_context(map() | struct(), module()) :: map()
  def permission_context(actor, repo \\ UniboExPoc.Repo) do
    role_codes = role_codes(actor, repo)
    permission_keys = permission_keys(actor, repo)
    data_scope = data_scope(actor, repo)
    scope_party_ids = scope_party_ids(actor, repo)

    %{
      role_codes: role_codes,
      permission_keys: permission_keys,
      data_scope: data_scope,
      scope_party_ids: scope_party_ids
    }
  end

  @doc """
  判断 actor 是否具备指定功能权限。
  """
  @spec can?(map() | struct(), String.t(), module()) :: boolean()
  def can?(actor, permission_key, repo \\ UniboExPoc.Repo) when is_binary(permission_key) do
    permission_key in permission_keys(actor, repo)
  end

  @doc """
  补全给 #1177/GraphQL 运行时使用的 actor 上下文。
  """
  @spec to_abac_context(map() | struct(), module()) :: map()
  def to_abac_context(actor, repo \\ UniboExPoc.Repo) do
    context = permission_context(actor, repo)
    actor_map = if is_map(actor), do: Map.new(actor), else: %{}

    actor_map
    |> maybe_put_effective_role(context.role_codes)
    |> Map.put(:roles, context.role_codes)
    |> Map.put(:permission_keys, context.permission_keys)
    |> Map.put(:data_scope, context.data_scope)
    |> Map.put(:scope_party_ids, context.scope_party_ids)
  end

  defp active_roles(actor, repo) do
    actor
    |> actor_party_id()
    |> active_role_assignments(repo)
    |> Enum.map(& &1.role_id)
    |> fetch_roles(repo)
  end

  defp active_role_assignments(nil, _repo), do: []

  defp active_role_assignments(party_id, _repo) do
    now = DateTime.utc_now()

    RoleAssignment
    |> Query.for_read(:read)
    |> Query.filter(
      expr(
        party_id == ^party_id and
          status == :active and
          (is_nil(active_from) or active_from <= ^now) and
          (is_nil(active_until) or active_until > ^now)
      )
    )
    |> Ash.read!(authorize?: false)
  end

  defp fetch_roles([], _repo), do: []

  defp fetch_roles(role_ids, _repo) do
    Role
    |> Query.for_read(:read)
    |> Query.filter(expr(id in ^role_ids and status == :active))
    |> Ash.read!(authorize?: false)
  end

  defp fetch_permission_keys([], _repo), do: []

  defp fetch_permission_keys(role_ids, _repo) do
    permission_ids =
      RolePermissionGrant
      |> Query.for_read(:read)
      |> Query.filter(expr(role_id in ^role_ids))
      |> Ash.read!(authorize?: false)
      |> Enum.map(& &1.permission_node_id)
      |> Enum.uniq()

    case permission_ids do
      [] ->
        []

      ids ->
        PermissionNode
        |> Query.for_read(:read)
        |> Query.filter(expr(id in ^ids and status == :active))
        |> Ash.read!(authorize?: false)
        |> Enum.map(& &1.key)
    end
  end

  defp fetch_scope_levels([], _repo), do: []

  defp fetch_scope_levels(role_ids, _repo) do
    RoleDataScopeGrant
    |> Query.for_read(:read)
    |> Query.filter(expr(role_id in ^role_ids))
    |> Ash.read!(authorize?: false)
    |> Enum.map(& &1.scope_level)
  end

  defp max_scope_level([]), do: :self

  defp max_scope_level(levels) do
    Enum.max_by(levels, fn level -> Map.get(@scope_rank, level, 0) end)
  end

  defp maybe_put_effective_role(actor_map, role_codes) when is_map(actor_map) do
    current_role = actor_role(actor_map)
    effective_role = infer_effective_role(role_codes)

    cond do
      is_nil(effective_role) ->
        actor_map

      is_nil(current_role) ->
        Map.put(actor_map, :role, effective_role)

      should_replace_role?(current_role, effective_role) ->
        actor_map
        |> Map.put_new(:auth_role, current_role)
        |> Map.put(:role, effective_role)

      true ->
        actor_map
    end
  end

  defp actor_role(%{role: role}) when is_binary(role) and role != "", do: role
  defp actor_role(%{"role" => role}) when is_binary(role) and role != "", do: role
  defp actor_role(_), do: nil

  defp infer_effective_role(role_codes) when is_list(role_codes) do
    cond do
      "admin" in role_codes -> "admin"
      length(role_codes) == 1 -> hd(role_codes)
      true -> nil
    end
  end

  defp should_replace_role?(current_role, effective_role) do
    current_role != effective_role and
      (current_role in ["member", "employee", "user"] or effective_role == "admin")
  end

  defp actor_party_id(%{party_id: party_id}), do: party_id
  defp actor_party_id(%{"party_id" => party_id}), do: party_id
  defp actor_party_id(_), do: nil
end
