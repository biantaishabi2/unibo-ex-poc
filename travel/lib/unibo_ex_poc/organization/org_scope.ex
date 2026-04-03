defmodule UniboExPoc.Organization.OrgScope do
  @moduledoc """
  组织范围计算——给定 actor 的 party_id，返回其可访问的所有 party_id。

  简单版：直接返回 actor 自身的 party_id（不递归）。
  完整版：基于 PartyRelationship 资源按 frontier 分批查询，
  沿 subsidiary_of/belongs_to_org 向下展开。
  """

  @doc """
  简单版 org_scope：返回 actor 自身的 party_id 列表（不递归）。
  适用于单组织场景，无需递归展开。
  """
  @spec resolve_simple(Ecto.UUID.t()) :: [Ecto.UUID.t()]
  def resolve_simple(actor_party_id) when is_binary(actor_party_id) do
    [actor_party_id]
  end

  def resolve_simple(nil), do: []

  require Ash.Query

  @scope_cache_key {__MODULE__, :scope_cache}
  @scope_cache_ref_key {__MODULE__, :scope_cache_ref}

  @doc """
  完整版 org_scope：基于 PartyRelationship 资源递归计算 actor 可访问的所有组织 ID。
  每一轮只查询当前 frontier 对应的有效组织关系，
  避免每次读取全部 PartyRelationship。

  默认不跨调用缓存，避免把授权结果缓存脏掉。
  如需在一段显式的纯读取链中复用结果，可配合 `with_scope_cache/1` 使用。

  返回 party_id 列表（包含 actor 自身）。
  """
  @spec resolve(Ecto.UUID.t(), module()) :: [Ecto.UUID.t()]
  def resolve(actor_party_id, repo \\ UniboExPoc.Repo)

  def resolve(nil, _repo), do: []

  def resolve(actor_party_id, repo) when is_binary(actor_party_id) do
    case current_scope_cache_ref() do
      nil ->
        resolve_uncached(actor_party_id)

      cache_ref ->
        case cache_get(cache_ref, actor_party_id, repo) do
          {:ok, cached} ->
            cached

          :error ->
            resolved = resolve_uncached(actor_party_id)
            cache_put(cache_ref, actor_party_id, repo, resolved)
            resolved
        end
    end
  end

  @doc """
  在一段显式的纯读取链内复用 org_scope 解析结果。
  退出后会自动清理缓存，避免跨请求/跨写入保留脏数据。
  """
  @spec with_scope_cache((-> result)) :: result when result: var
  def with_scope_cache(fun) when is_function(fun, 0) do
    cache_ref = make_ref()
    previous_ref = Process.get(@scope_cache_ref_key)
    Process.put(@scope_cache_ref_key, cache_ref)

    try do
      fun.()
    after
      clear_scope_cache(cache_ref)
      if previous_ref do
        Process.put(@scope_cache_ref_key, previous_ref)
      else
        Process.delete(@scope_cache_ref_key)
      end
    end
  end

  defp expand_scope(scope, [], _now), do: scope

  defp expand_scope(scope, frontier, now) do
    relationships =
      UniboExPoc.Organization.PartyRelationship
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(
        to_party_id: [in: frontier],
        relationship_type: [in: [:subsidiary_of, :belongs_to_org]],
        from_date: [less_than_or_equal: now],
        or: [
          [thru_date: [is_nil: true]],
          [thru_date: [greater_than: now]]
        ]
      )
      |> Ash.read!(authorize?: false)

    next_frontier =
      relationships
      |> Enum.map(& &1.from_party_id)
      |> Enum.reject(&MapSet.member?(scope, &1))
      |> Enum.uniq()

    if next_frontier == [] do
      scope
    else
      next_scope =
        Enum.reduce(next_frontier, scope, fn party_id, acc -> MapSet.put(acc, party_id) end)

      expand_scope(next_scope, next_frontier, now)
    end
  end

  defp resolve_uncached(actor_party_id) do
    now = DateTime.utc_now()

    [actor_party_id]
    |> MapSet.new()
    |> expand_scope([actor_party_id], now)
    |> MapSet.to_list()
  end

  defp current_scope_cache_ref do
    Process.get(@scope_cache_ref_key)
  end

  defp cache_get(cache_ref, actor_party_id, repo) do
    @scope_cache_key
    |> Process.get(%{})
    |> Map.fetch({cache_ref, repo, actor_party_id})
  end

  defp cache_put(cache_ref, actor_party_id, repo, resolved) do
    cache =
      @scope_cache_key
      |> Process.get(%{})
      |> Map.put({cache_ref, repo, actor_party_id}, resolved)

    Process.put(@scope_cache_key, cache)
    resolved
  end

  defp clear_scope_cache(cache_ref) do
    cache =
      @scope_cache_key
      |> Process.get(%{})
      |> Enum.reject(fn {{entry_ref, _, _}, _} -> entry_ref == cache_ref end)
      |> Map.new()

    Process.put(@scope_cache_key, cache)
  end
end
