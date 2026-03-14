defmodule HospitalSchedulingWeb.Graphql.ActorContext do
  @moduledoc """
  GraphQL/BFF 统一 actor 上下文归一层（由 UniBO 自动生成）。

  认证来源可插拔：
  - conn.assigns[:actor] / :current_user / :principal / :auth_claims
  - GraphQL context 中的 actor / principal / claims
  - 内网/BFF 透传 header

  目标是统一产出标准 actor 结构，而不是把 runtime 绑定死到某一种认证介质。
  """

  def from_context(context) when is_map(context) do
    conn = Map.get(context, :conn) || Map.get(context, "conn")

    from_sources(%{
      actor:
        Map.get(context, :actor) ||
          Map.get(context, "actor") ||
          conn_assign(conn, :actor),
      current_user:
        Map.get(context, :current_user) ||
          Map.get(context, "current_user") ||
          conn_assign(conn, :current_user),
      principal:
        Map.get(context, :principal) ||
          Map.get(context, "principal") ||
          conn_assign(conn, :principal),
      authz:
        Map.get(context, :authz) ||
          Map.get(context, "authz") ||
          conn_assign(conn, :authz),
      claims:
        Map.get(context, :auth_claims) ||
          Map.get(context, "auth_claims") ||
          Map.get(context, :claims) ||
          Map.get(context, "claims") ||
          conn_assign(conn, :auth_claims) ||
          conn_assign(conn, :claims),
      conn: conn,
      party_id: Map.get(context, :party_id) || Map.get(context, "party_id")
    })
  end

  def from_context(_), do: nil

  def from_conn(%Plug.Conn{} = conn) do
    from_sources(%{
      actor: conn.assigns[:actor],
      current_user: conn.assigns[:current_user],
      principal: conn.assigns[:principal],
      authz: conn.assigns[:authz],
      claims: conn.assigns[:auth_claims] || conn.assigns[:claims],
      conn: conn
    })
  end

  def from_conn(_), do: nil

  def from_auth_result(user, claims, conn \\ nil) do
    from_sources(%{current_user: user, claims: claims, conn: conn})
  end

  def from_sources(sources) when is_map(sources) do
    [
      normalize(Map.get(sources, :actor)),
      actor_from_claims(Map.get(sources, :claims), Map.get(sources, :current_user)),
      normalize(Map.get(sources, :current_user)),
      actor_from_principal(sources),
      actor_from_headers(Map.get(sources, :conn))
    ]
    |> Enum.reject(&is_nil/1)
    |> merge_actor_candidates()
    |> enrich_with_access_control()
  end

  def from_sources(_), do: nil

  def normalize(actor) when is_map(actor) do
    actor_id =
      Map.get(actor, :id) ||
        Map.get(actor, "id") ||
        Map.get(actor, :user_id) ||
        Map.get(actor, "user_id") ||
        Map.get(actor, :member_id) ||
        Map.get(actor, "member_id") ||
        nested_id(Map.get(actor, :user) || Map.get(actor, "user"))

    normalized_id = normalize_string(actor_id)

    party_id =
      Map.get(actor, :party_id) ||
        Map.get(actor, "party_id") ||
        Map.get(actor, :partyId) ||
        Map.get(actor, "partyId") ||
        nested_id(Map.get(actor, :party) || Map.get(actor, "party")) ||
        nested_id(Map.get(actor, :principal) || Map.get(actor, "principal"))

    normalized_party_id = normalize_string(party_id)

    role =
      Map.get(actor, :role) ||
        Map.get(actor, "role") ||
        first_role(Map.get(actor, :roles) || Map.get(actor, "roles"))

    normalized_role = normalize_string(role)

    roles =
      Map.get(actor, :roles) ||
        Map.get(actor, "roles") ||
        normalize_claim_roles(Map.get(actor, :role) || Map.get(actor, "role"))

    normalized_roles = normalize_roles(roles)

    actor_type =
      Map.get(actor, :type) ||
        Map.get(actor, "type")

    normalized_type = normalize_string(actor_type)

    if normalized_id == "" do
      nil
    else
      %{}
      |> Map.put(:id, normalized_id)
      |> maybe_put_actor_field(:party_id, normalized_party_id)
      |> maybe_put_actor_field(:role, normalized_role)
      |> maybe_put_actor_field(:roles, normalized_roles)
      |> maybe_put_actor_field(:type, normalized_type)
    end
  end

  def normalize(_), do: nil

  def actor_from_principal(context) when is_map(context) do
    principal = Map.get(context, :principal) || Map.get(context, "principal")
    authz = Map.get(context, :authz) || Map.get(context, "authz")

    actor_id =
      map_value(principal, "id") ||
        map_value(principal, "user_id") ||
        map_value(principal, "member_id")

    normalized_id = normalize_string(actor_id)

    party_id =
      map_value(principal, "party_id") ||
        Map.get(context, :party_id) ||
        Map.get(context, "party_id") ||
        header_value(Map.get(context, :conn) || Map.get(context, "conn"), "x-party-id") ||
        header_value(Map.get(context, :conn) || Map.get(context, "conn"), "x-actor-party-id")

    normalized_party_id = normalize_string(party_id)
    role = map_value(principal, "role") || first_role(map_value(authz, "roles"))
    normalized_role = normalize_string(role)
    roles = normalize_roles(map_value(authz, "roles"))
    actor_type = normalize_string(map_value(principal, "type"))

    if normalized_id == "" do
      nil
    else
      %{}
      |> Map.put(:id, normalized_id)
      |> maybe_put_actor_field(:party_id, normalized_party_id)
      |> maybe_put_actor_field(:role, normalized_role)
      |> maybe_put_actor_field(:roles, roles)
      |> maybe_put_actor_field(:type, actor_type)
    end
  end

  def actor_from_principal(_), do: nil

  def actor_from_claims(claims, user \\ nil)

  def actor_from_claims(claims, user) when is_map(claims) do
    claim_actor =
      %{}
      |> Map.put(
        :id,
        map_value(claims, "sub") ||
          map_value(claims, "id") ||
          map_value(claims, "user_id")
      )
      |> maybe_put_claim_field(
        :party_id,
        map_value(claims, "party_id") ||
          map_value(claims, "partyId") ||
          nested_id(map_value(claims, "party"))
      )
      |> maybe_put_claim_field(:role, map_value(claims, "role"))
      |> maybe_put_claim_field(:roles, map_value(claims, "roles"))
      |> maybe_put_claim_field(:type, map_value(claims, "type"))

    normalize(Map.merge(claim_actor, normalize(user) || %{}))
  end

  def actor_from_claims(_, user), do: normalize(user)

  def actor_from_headers(%Plug.Conn{} = conn) do
    actor_id = List.first(Plug.Conn.get_req_header(conn, "x-actor-id"))
    actor_role = List.first(Plug.Conn.get_req_header(conn, "x-actor-role"))

    actor_party_id =
      List.first(Plug.Conn.get_req_header(conn, "x-actor-party-id")) ||
        List.first(Plug.Conn.get_req_header(conn, "x-party-id"))

    case normalize_string(actor_id) do
      "" ->
        nil

      id ->
        %{id: id, role: normalize_string(actor_role)}
        |> maybe_put_actor_field(:party_id, normalize_string(actor_party_id))
    end
  end

  def actor_from_headers(_), do: nil

  defp maybe_put_claim_field(actor, _field, nil), do: actor
  defp maybe_put_claim_field(actor, field, value), do: Map.put(actor, field, value)

  defp maybe_put_actor_field(actor, _field, ""), do: actor
  defp maybe_put_actor_field(actor, _field, []), do: actor
  defp maybe_put_actor_field(actor, field, value), do: Map.put(actor, field, value)

  defp nested_id(value) when is_map(value) do
    Map.get(value, :id) || Map.get(value, "id") || Map.get(value, :party_id) ||
      Map.get(value, "party_id")
  end

  defp nested_id(_), do: nil

  defp normalize_claim_roles(nil), do: []
  defp normalize_claim_roles(value), do: [value]

  defp conn_assign(%Plug.Conn{assigns: assigns}, key) when is_atom(key), do: Map.get(assigns, key)
  defp conn_assign(_, _), do: nil

  defp merge_actor_candidates([]), do: nil
  defp merge_actor_candidates([actor | rest]), do: Enum.reduce(rest, actor, &merge_actor/2)

  defp merge_actor(candidate, existing) when not is_map(existing), do: candidate
  defp merge_actor(candidate, existing) when not is_map(candidate), do: existing

  defp merge_actor(candidate, existing) do
    existing_id = Map.get(existing, :id)
    candidate_id = Map.get(candidate, :id)

    cond do
      existing_id in [nil, ""] ->
        candidate

      candidate_id in [nil, ""] ->
        existing

      existing_id != candidate_id ->
        existing

      true ->
        existing
        |> maybe_put_missing_actor_field(:party_id, Map.get(candidate, :party_id))
        |> maybe_put_missing_actor_field(:role, Map.get(candidate, :role))
        |> maybe_put_missing_actor_field(:roles, Map.get(candidate, :roles))
        |> maybe_put_missing_actor_field(:type, Map.get(candidate, :type))
    end
  end

  defp enrich_with_access_control(nil), do: nil

  defp enrich_with_access_control(actor) when is_map(actor) do
    party_id = Map.get(actor, :party_id)

    cond do
      normalize_string(party_id) == "" ->
        actor

      true ->
        case access_control_module() do
          nil ->
            actor

          module ->
            with_org_scope_cache(fn ->
              apply(module, :to_abac_context, [actor])
            end)
        end
    end
  rescue
    _ -> actor
  end

  defp enrich_with_access_control(actor), do: actor

  defp with_org_scope_cache(fun) when is_function(fun, 0) do
    case org_scope_module() do
      nil -> fun.()
      module -> apply(module, :with_scope_cache, [fun])
    end
  end

  defp access_control_module do
    module = HospitalScheduling.Organization.AccessControl

    if Code.ensure_loaded?(module) and function_exported?(module, :to_abac_context, 1) do
      module
    else
      nil
    end
  end

  defp org_scope_module do
    module = HospitalScheduling.Organization.OrgScope

    if Code.ensure_loaded?(module) and function_exported?(module, :with_scope_cache, 1) do
      module
    else
      nil
    end
  end

  defp maybe_put_missing_actor_field(actor, field, value)
       when field in [:party_id, :role, :type] do
    case Map.get(actor, field) do
      nil -> maybe_put_actor_field(actor, field, value)
      "" -> maybe_put_actor_field(actor, field, value)
      _ -> actor
    end
  end

  defp maybe_put_missing_actor_field(actor, :roles, value) do
    case Map.get(actor, :roles) do
      nil -> maybe_put_actor_field(actor, :roles, value)
      [] -> maybe_put_actor_field(actor, :roles, value)
      _ -> actor
    end
  end

  defp first_role([]), do: nil
  defp first_role([role | _]), do: role
  defp first_role(_), do: nil

  defp normalize_roles(nil), do: []

  defp normalize_roles(value) when is_binary(value),
    do:
      value
      |> String.split(",", trim: true)
      |> Enum.map(&normalize_string/1)
      |> Enum.reject(&(&1 == ""))

  defp normalize_roles(value) when is_list(value),
    do: value |> Enum.map(&normalize_string/1) |> Enum.reject(&(&1 == ""))

  defp normalize_roles(_), do: []

  defp map_value(nil, _key), do: nil

  defp map_value(map, key) when is_map(map) do
    normalized_key = normalize_string(key)

    Enum.find_value(map, fn {existing_key, value} ->
      if normalize_string(existing_key) == normalized_key do
        value
      else
        nil
      end
    end)
  end

  defp map_value(_, _key), do: nil

  defp header_value(%Plug.Conn{} = conn, name) when is_binary(name) do
    conn
    |> Plug.Conn.get_req_header(name)
    |> List.first()
  end

  defp header_value(_, _), do: nil

  defp normalize_string(nil), do: ""
  defp normalize_string(value) when is_binary(value), do: String.trim(value)
  defp normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  defp normalize_string(value) when is_integer(value), do: Integer.to_string(value)

  defp normalize_string(value) when is_float(value),
    do: :erlang.float_to_binary(value, [:compact, decimals: 6])

  defp normalize_string(_), do: ""
end
