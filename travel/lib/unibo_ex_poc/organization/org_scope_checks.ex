defmodule UniboExPoc.Organization.OrgScopeChecks.PartyInScope do
  @moduledoc """
  Organization 域 Party 读取范围过滤：
  通过 OrgScope 解析 actor 可访问的 party_id 列表，再按 id 过滤。
  """

  use Ash.Policy.Check
  @behaviour Ash.Policy.FilterCheck

  def filter(actor, _authorizer, _opts) do
    ids =
      actor
      |> actor_party_id()
      |> UniboExPoc.Organization.OrgScope.resolve(UniboExPoc.Repo)

    expr(id in ^ids)
  end

  def auto_filter(actor, authorizer, opts), do: filter(actor, authorizer, opts)

  def check(actor, data, authorizer, opts) do
    ids =
      actor
      |> actor_party_id()
      |> UniboExPoc.Organization.OrgScope.resolve(UniboExPoc.Repo)
      |> MapSet.new()

    _ = authorizer
    _ = opts

    Enum.filter(data, &MapSet.member?(ids, &1.id))
  end

  def strict_check(actor, _authorizer, _opts) do
    case actor_party_id(actor) do
      party_id when is_binary(party_id) and byte_size(party_id) > 0 -> {:ok, :unknown}
      _ -> {:ok, false}
    end
  end

  def describe(_opts), do: "party_in_org_scope"

  def type, do: :filter

  defp actor_party_id(%{party_id: party_id}), do: party_id
  defp actor_party_id(_), do: nil
end

defmodule UniboExPoc.Organization.OrgScopeChecks.PartyRoleInScope do
  @moduledoc """
  Organization 域 PartyRole 读取范围过滤：
  通过 OrgScope 解析 actor 可访问的 party_id 列表，再按 party_id 过滤。
  """

  use Ash.Policy.Check
  @behaviour Ash.Policy.FilterCheck

  def filter(actor, _authorizer, _opts) do
    ids =
      actor
      |> actor_party_id()
      |> UniboExPoc.Organization.OrgScope.resolve(UniboExPoc.Repo)

    expr(party_id in ^ids)
  end

  def auto_filter(actor, authorizer, opts), do: filter(actor, authorizer, opts)

  def check(actor, data, authorizer, opts) do
    ids =
      actor
      |> actor_party_id()
      |> UniboExPoc.Organization.OrgScope.resolve(UniboExPoc.Repo)
      |> MapSet.new()

    _ = authorizer
    _ = opts

    Enum.filter(data, &MapSet.member?(ids, &1.party_id))
  end

  def strict_check(actor, _authorizer, _opts) do
    case actor_party_id(actor) do
      party_id when is_binary(party_id) and byte_size(party_id) > 0 -> {:ok, :unknown}
      _ -> {:ok, false}
    end
  end

  def describe(_opts), do: "party_role_in_org_scope"

  def type, do: :filter

  defp actor_party_id(%{party_id: party_id}), do: party_id
  defp actor_party_id(_), do: nil
end

defmodule UniboExPoc.Organization.OrgScopeChecks.PartyRelationshipInScope do
  @moduledoc """
  Organization 域 PartyRelationship 读取范围过滤：
  仅允许有效的组织关系（subsidiary_of / belongs_to_org），
  且要求 from/to 任一端点落在 actor 的 org_scope 内。
  """

  use Ash.Policy.Check
  @behaviour Ash.Policy.FilterCheck

  def filter(actor, _authorizer, _opts) do
    ids =
      actor
      |> actor_party_id()
      |> UniboExPoc.Organization.OrgScope.resolve(UniboExPoc.Repo)

    now = DateTime.utc_now()

    expr(
      relationship_type in [:subsidiary_of, :belongs_to_org] and
        (from_party_id in ^ids or to_party_id in ^ids) and
        from_date <= ^now and
        (is_nil(thru_date) or thru_date > ^now)
    )
  end

  def auto_filter(actor, authorizer, opts), do: filter(actor, authorizer, opts)

  def check(actor, data, authorizer, opts) do
    ids =
      actor
      |> actor_party_id()
      |> UniboExPoc.Organization.OrgScope.resolve(UniboExPoc.Repo)
      |> MapSet.new()

    now = DateTime.utc_now()
    _ = authorizer
    _ = opts

    Enum.filter(data, fn rel ->
      rel.relationship_type in [:subsidiary_of, :belongs_to_org] and
        (MapSet.member?(ids, rel.from_party_id) or MapSet.member?(ids, rel.to_party_id)) and
        DateTime.compare(rel.from_date, now) != :gt and
        (is_nil(rel.thru_date) or DateTime.compare(rel.thru_date, now) == :gt)
    end)
  end

  def strict_check(actor, _authorizer, _opts) do
    case actor_party_id(actor) do
      party_id when is_binary(party_id) and byte_size(party_id) > 0 -> {:ok, :unknown}
      _ -> {:ok, false}
    end
  end

  def describe(_opts), do: "party_relationship_in_org_scope"

  def type, do: :filter

  defp actor_party_id(%{party_id: party_id}), do: party_id
  defp actor_party_id(_), do: nil
end
