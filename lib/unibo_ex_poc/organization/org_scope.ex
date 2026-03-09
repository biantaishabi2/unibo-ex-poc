defmodule UniboExPoc.Organization.OrgScope do
  @moduledoc """
  组织范围计算——给定 actor 的 party_id，返回其可访问的所有 party_id。

  简单版：直接返回 actor 自身的 party_id（不递归）。
  完整版：通过递归 CTE 沿 subsidiary_of/belongs_to_org 向下展开。
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

  @doc """
  完整版 org_scope：通过递归 CTE 计算 actor 可访问的所有组织 ID。
  沿 PartyRelationship(type=subsidiary_of/belongs_to_org) 向下展开，
  过滤掉 thru_date < now 的过期关系。

  返回 party_id 列表（包含 actor 自身）。
  """
  @spec resolve(Ecto.UUID.t(), module()) :: [Ecto.UUID.t()]
  def resolve(actor_party_id, repo \\ UniboExPoc.Repo)

  def resolve(nil, _repo), do: []

  def resolve(actor_party_id, repo) when is_binary(actor_party_id) do
    query = \"\"\"
    WITH RECURSIVE org_tree AS (
      -- 起点：actor 自身
      SELECT id FROM organization_parties WHERE id = $1
      UNION
      -- 递归：沿 subsidiary_of/belongs_to_org 向下展开
      SELECT pr.from_party_id
      FROM organization_party_relationships pr
      JOIN org_tree ot ON pr.to_party_id = ot.id
      WHERE pr.relationship_type IN ('subsidiary_of', 'belongs_to_org')
        AND pr.from_date <= NOW()
        AND (pr.thru_date IS NULL OR pr.thru_date > NOW())
    )
    SELECT id FROM org_tree
    \"\"\"

    case repo.query(query, [actor_party_id]) do
      {:ok, %{rows: rows}} -> Enum.map(rows, fn [id] -> id end)
      _ -> [actor_party_id]
    end
  end
end
