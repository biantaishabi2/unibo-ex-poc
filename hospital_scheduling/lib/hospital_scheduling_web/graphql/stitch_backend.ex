defmodule HospitalSchedulingWeb.Graphql.StitchBackend do
  @moduledoc """
  Stitch -> GraphQL backend adapter / runtime bridge（由 UniBO 自动生成）。

  目标：
  - 根据 frontend_manifest/pages[*].api_map 为 Stitch 页面解析 backend contract
  - 将 Stitch 的 __load__/event 调度翻译成 GraphQL query/mutation
  - 把 GraphQL 返回收口成 {:ok, %{dto, status, effects, errors, meta}} 约定
  """

  alias HospitalSchedulingWeb.Graphql.RuntimeConfig
  alias HospitalSchedulingWeb.GraphqlController

  @load_event "__load__"
  @default_selection "id"

  def contract(page_id) when is_binary(page_id) do
    with {:ok, page} <- page(page_id) do
      {:ok,
       %{}
       |> Map.put("page_id", page_id)
       |> Map.put("backend", %{}
         |> Map.put("mode", "api")
         |> Map.put("api", %{"module" => Atom.to_string(__MODULE__), "fun" => "dispatch"})
         |> Map.put("load", %{"event" => @load_event})
         |> Map.put("api_map", map_get(page, "api_map") || %{}))}
    end
  end

  def contract(_page_id), do: {:error, :stitch_backend_page_not_found}

  def dispatch(event, params, state) do
    params = normalize_map(params)
    state = normalize_map(state)

    with {:ok, page_id} <- resolve_page_id(params, state),
         {:ok, page} <- page(page_id),
         {:ok, operation} <- resolve_operation(page, event, params),
         {:ok, query, variables} <- build_graphql_request(page, operation, params, state),
         {:ok, result} <- call_graphql(query, variables, state),
         {:ok, backend_result} <- normalize_backend_result(page, operation, result) do
      {:ok, backend_result}
    else
      {:error, :stitch_backend_load_skip} ->
        {:ok, %{dto: %{}, status: %{}, effects: []}}
      error -> error
    end
  end

  defp resolve_page_id(params, state) do
    page_id =
      normalize_string(map_get(params, "__page_id")) ||
        normalize_string(map_get(state, "__page_id")) ||
        normalize_string(map_get(map_get(state, "_meta") || %{}, "page_id"))

    case page_id do
      "" -> {:error, :stitch_backend_page_not_found}
      value -> {:ok, value}
    end
  end

  defp page(page_id) when is_binary(page_id) do
    RuntimeConfig.frontend_backend_page(page_id)
  end

  defp page(_page_id), do: {:error, :stitch_backend_page_not_found}

  defp resolve_operation(page, event, params) do
    api_map = normalize_map(map_get(page, "api_map"))
    normalized_event = normalize_string(event)
    api_key = resolve_api_key(api_map, normalized_event, normalize_string(map_get(page, "page_kind")), params)

    if api_key == "" and normalized_event == @load_event do
      {:error, :stitch_backend_load_skip}
    else
      with false <- api_key == "",
           api_ref when is_binary(api_ref) and api_ref != "" <- map_get(api_map, api_key),
           {:ok, parsed} <- parse_api_ref(api_ref),
           {:ok, field, field_meta} <- resolve_graphql_field(parsed, api_key) do
        {:ok,
         parsed
         |> Map.put("api_key", api_key)
         |> Map.put("field", field)
         |> Map.put("input_type", map_get(field_meta, "input_type"))
         |> Map.put("field_mode", map_get(field_meta, "mode"))
         |> Map.put("field_action", map_get(field_meta, "action"))
         |> Map.put("page_kind", normalize_string(map_get(page, "page_kind")))}
      else
        true -> {:error, :stitch_backend_api_missing}
        _ -> {:error, :stitch_backend_graphql_contract_missing}
      end
    end
  end

  defp resolve_api_key(api_map, event, page_kind, params) do
    normalized = normalize_string(event)
    stripped = String.replace_prefix(normalized, "action_", "")

    cond do
      normalized == @load_event and page_kind == "list" ->
        "list"

      normalized == @load_event and map_has_key?(api_map, "get") ->
        "get"

      normalized == @load_event and map_has_key?(api_map, "list") ->
        "list"

      normalized == @load_event and not map_has_key?(api_map, "get") and not map_has_key?(api_map, "list") ->
        ""

      normalized == @load_event ->
        "get"

      map_has_key?(api_map, normalized) ->
        normalized

      map_has_key?(api_map, stripped) ->
        stripped

      page_kind == "list" and normalized in ["filter_submit", "search_submit", "reload", "refresh", "form_submit"] and map_has_key?(api_map, "list") ->
        "list"

      page_kind == "detail" and normalized == "form_submit" and normalize_string(map_get(params, "id")) == "" and map_has_key?(api_map, "create") ->
        "create"

      page_kind == "detail" and normalized == "form_submit" and map_has_key?(api_map, "update") ->
        "update"

      page_kind == "detail" and normalize_string(map_get(params, "id")) != "" and map_has_key?(api_map, "get") ->
        "get"

      true ->
        ""
    end
  end

  defp parse_api_ref(api_ref) when is_binary(api_ref) do
    case String.split(api_ref, ".", trim: true) do
      [domain, entity, action] ->
        {:ok,
         %{"domain" => domain, "entity" => entity, "action" => action}}

      _ ->
        {:error, :stitch_backend_api_ref_invalid}
    end
  end

  defp parse_api_ref(_api_ref), do: {:error, :stitch_backend_api_ref_invalid}

  defp resolve_graphql_field(parsed, api_key) do
    entity = normalize_string(map_get(parsed, "entity"))
    action = normalize_string(map_get(parsed, "action"))
    fields = RuntimeConfig.manifest() |> map_get("fields") |> normalize_list()

    candidate =
      cond do
        api_key in ["list", "get", "create", "update", "destroy"] ->
          Enum.find(fields, fn field ->
            normalize_string(map_get(field, "entity")) == entity and
              normalize_string(map_get(field, "mode")) == api_key
          end)

        true ->
          Enum.find(fields, fn field ->
            normalize_string(map_get(field, "entity")) == entity and
              normalize_string(map_get(field, "action")) == action
          end)
      end

    case normalize_string(map_get(candidate || %{}, "field")) do
      "" ->
        {:error, :stitch_backend_graphql_contract_missing}

      value ->
        {:ok, value,
         %{"input_type" => normalize_string(map_get(candidate, "input_type")),
            "mode" => normalize_string(map_get(candidate, "mode")),
            "action" => normalize_string(map_get(candidate, "action"))}}
    end
  end

  defp build_graphql_request(page, operation, params, state) do
    field = normalize_string(map_get(operation, "field"))
    api_key = normalize_string(map_get(operation, "api_key"))
    input_type = normalize_string(map_get(operation, "input_type"))
    field_mode = normalize_string(map_get(operation, "field_mode"))
    selection = selection_set(page, operation, state)

    case api_key do
      "list" ->
        {:ok,
         "query StitchList { #{field} { results { #{selection} } count } }",
         %{}}

      "get" ->
        id =
          normalize_string(map_get(params, "id")) ||
            normalize_string(map_get(state, "id")) ||
            normalize_string(map_get(map_get(state, "record") || %{}, "id"))

        {:ok,
         "query StitchGet($id: ID!) { #{field}(id: $id) { #{selection} } }",
         %{"id" => id}}

      "create" ->
        input = sanitize_input_params(params)
        {decl, arg} = input_type_decl(input_type)

        {:ok,
         "mutation StitchCreate(#{decl}) { #{field}(#{arg}) { result { #{selection} } errors { message code } } }",
         %{"input" => input}}

      "update" ->
        id = resolve_id(params, state)
        input = sanitize_input_params(params) |> Map.delete("id")
        {decl, arg} = input_type_decl(input_type)

        {:ok,
         "mutation StitchUpdate($id: ID!, #{decl}) { #{field}(id: $id, #{arg}) { result { #{selection} } errors { message code } } }",
         %{"id" => id, "input" => input}}

      "destroy" ->
        id = resolve_id(params, state)

        {:ok,
         "mutation StitchDestroy($id: ID!) { #{field}(id: $id) { result { #{selection} } errors { message code } } }",
         %{"id" => id}}

      _ ->
        build_custom_action_request(field, field_mode, input_type, params, state, selection)
    end
  end

  defp build_custom_action_request(field, _field_mode, input_type, params, state, selection) do
    id = resolve_id(params, state)

    cond do
      input_type != "" ->
        input = sanitize_input_params(params) |> Map.delete("id")
        {decl, arg} = input_type_decl(input_type)

        {:ok,
         "mutation StitchAction($id: ID!, #{decl}) { #{field}(id: $id, #{arg}) { result { #{selection} } errors { message code } } }",
         %{"id" => id, "input" => input}}

      id != "" ->
        {:ok,
         "mutation StitchAction($id: ID!) { #{field}(id: $id) { result { #{selection} } errors { message code } } }",
         %{"id" => id}}

      true ->
        {:ok,
         "mutation StitchAction { #{field} { result { #{selection} } errors { message code } } }",
         %{}}
    end
  end

  defp resolve_id(params, state) do
    normalize_string(map_get(params, "id")) ||
      normalize_string(map_get(state, "id")) ||
      normalize_string(map_get(map_get(state, "record") || %{}, "id"))
  end

  defp input_type_decl(input_type) when input_type != "" do
    {"$input: #{input_type}!", "input: $input"}
  end

  defp input_type_decl(_input_type) do
    {"$input: JSON", "input: $input"}
  end

  defp call_graphql(query, variables, state) do
    conn = synthetic_conn(state)
    base_context = RuntimeConfig.build_context(context_from_state(conn, state))
    GraphqlController.call_graphql(conn, query, variables, base_context)
  end

  defp context_from_state(conn, state) do
    %{}
    |> Map.put(:conn, conn)
    |> put_if_present(:actor, map_get(state, "actor"))
    |> put_if_present(:current_user, map_get(state, "current_user"))
    |> put_if_present(:auth_claims, map_get(state, "auth_claims") || map_get(state, "claims"))
    |> put_if_present(:tenant_id, map_get(state, "tenant_id"))
    |> put_if_present(:tenant, map_get(state, "tenant"))
    |> put_if_present(:context_envelope, map_get(state, "context_envelope"))
    |> put_if_present(:scope, map_get(state, "scope"))
    |> put_if_present(:authz, map_get(state, "authz"))
    |> put_if_present(:correlation, map_get(state, "correlation"))
  end

  defp synthetic_conn(state) do
    assigns =
      %{}
      |> put_if_present(:actor, map_get(state, "actor"))
      |> put_if_present(:current_user, map_get(state, "current_user"))
      |> put_if_present(:auth_claims, map_get(state, "auth_claims"))

    struct(Plug.Conn, %{req_headers: normalize_headers(map_get(state, "headers")), assigns: assigns})
  end

  defp normalize_backend_result(page, operation, result) when is_map(result) do
    field = normalize_string(map_get(operation, "field"))
    data = map_get(result, :data) || map_get(result, "data") || %{}
    errors = normalize_errors(map_get(result, :errors) || map_get(result, "errors") || [])
    value = map_get(data, field)
    status = adapt_status(page, operation, value)
    dto = adapt_dto(page, operation, value)

    {:ok,
     %{}
     |> Map.put(:dto, dto)
     |> Map.put(:status, status)
     |> Map.put(:effects, [])
     |> Map.put(:errors, errors)
     |> Map.put(:meta, %{"page_id" => map_get(page, "page_id"), "field" => field, "api_key" => map_get(operation, "api_key")})}
  end

  defp normalize_backend_result(_page, _operation, _result), do: {:error, :stitch_backend_invalid_result}

  defp adapt_status(page, operation, value) do
    defaults =
      page
      |> map_get("state_schema")
      |> map_get("defaults")
      |> normalize_map()

    status_keys =
      page
      |> map_get("status_keys")
      |> normalize_string_list()

    state =
      Enum.reduce(status_keys, defaults, fn key, acc ->
        Map.put_new(acc, key, nil)
      end)

    case normalize_string(map_get(page, "page_kind")) do
      "list" ->
        rows = extract_rows(value)

        state
        |> Map.put("rows", rows)
        |> Map.put("rows_empty", rows == [])
        |> Map.put("loading", false)

      _ ->
        record = extract_record(value)

        state
        |> Map.put("record", record)
        |> Map.put("form", state["form"] || record)
        |> Map.put("loading", false)
    end
  end

  defp adapt_dto(page, _operation, value) do
    case normalize_string(map_get(page, "page_kind")) do
      "list" ->
        %{"rows" => extract_rows(value), "raw" => value}

      _ ->
        record = extract_record(value)
        %{"record" => record, "raw" => value}
    end
  end

  defp extract_rows(value) when is_list(value), do: value

  defp extract_rows(value) when is_map(value) do
    cond do
      is_list(map_get(value, "results")) -> map_get(value, "results")
      is_list(map_get(value, "result")) -> map_get(value, "result")
      is_list(map_get(value, "rows")) -> map_get(value, "rows")
      true -> []
    end
  end

  defp extract_rows(_value), do: []

  defp extract_record(value) when is_map(value) do
    cond do
      is_map(map_get(value, "result")) -> map_get(value, "result")
      is_map(map_get(value, "record")) -> map_get(value, "record")
      true -> value
    end
  end

  defp extract_record(value) when is_list(value), do: Enum.find(value, &is_map/1) || %{}
  defp extract_record(_value), do: %{}

  defp selection_set(page, _operation, state) do
    state
    |> map_get("selection")
    |> normalize_string()
    |> case do
      "" -> build_selection_from_page(page)
      value -> value
    end
  end

  defp build_selection_from_page(page) do
    page
    |> map_get("state_schema")
    |> map_get("defaults")
    |> normalize_map()
    |> build_selection_from_defaults()
  end

  defp build_selection_from_defaults(defaults) do
    rows = map_get(defaults, "rows")
    record = map_get(defaults, "record")
    form = map_get(defaults, "form")

    sample =
      cond do
        is_list(rows) and match?([first | _] when is_map(first), rows) ->
          List.first(rows)

        is_map(record) and map_size(record) > 0 ->
          record

        is_map(form) and map_size(form) > 0 ->
          form

        true ->
          %{}
      end

    fields = extract_selection_fields(sample)

    case fields do
      "" -> @default_selection
      value -> "id " <> value
    end
  end

  defp extract_selection_fields(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.reject(&(&1 in [:id, :__struct__, :__meta__]))
    |> Enum.map(fn key ->
      value = Map.get(map, key)
      key_str = to_string(key)

      cond do
        is_map(value) and not Map.has_key?(value, :__struct__) and map_size(value) > 0 ->
          nested = extract_selection_fields(value)
          if nested == "", do: key_str, else: key_str <> " { " <> nested <> " }"

        is_list(value) ->
          case value do
            [first | _] when is_map(first) ->
              nested = extract_selection_fields(first)
              if nested == "", do: key_str, else: key_str <> " { " <> nested <> " }"

            _ ->
              key_str
          end

        true ->
          key_str
      end
    end)
    |> Enum.join(" ")
  end

  defp extract_selection_fields(_), do: ""

  defp sanitize_input_params(params) do
    params
    |> normalize_map()
    |> Map.drop(["__page_id", "_target", "_csrf_token"])
  end

  defp normalize_errors(errors) when is_list(errors) do
    Enum.map(errors, fn
      error when is_map(error) -> normalize_map(error)
      error -> %{"message" => to_string(error)}
    end)
  end

  defp normalize_errors(_errors), do: []

  defp normalize_headers(headers) when is_list(headers) do
    Enum.map(headers, fn
      {key, value} -> {to_string(key), to_string(value)}
      [key, value] -> {to_string(key), to_string(value)}
      %{"name" => key, "value" => value} -> {to_string(key), to_string(value)}
      _ -> {"x-ignore", ""}
    end)
    |> Enum.reject(fn {key, _value} -> key == "x-ignore" end)
  end

  defp normalize_headers(_headers), do: []

  defp put_if_present(map, _key, nil), do: map
  defp put_if_present(map, _key, ""), do: map
  defp put_if_present(map, key, value), do: Map.put(map, key, value)

  defp normalize_map(value) when is_map(value) do
    Enum.reduce(value, %{}, fn
      {key, value}, acc when is_atom(key) -> Map.put(acc, Atom.to_string(key), value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, key, value)
      _, acc -> acc
    end)
  end

  defp normalize_map(_value), do: %{}

  defp normalize_list(values) when is_list(values), do: values
  defp normalize_list(_values), do: []

  defp normalize_string_list(values) when is_list(values) do
    values
    |> Enum.filter(&is_binary/1)
  end

  defp normalize_string_list(_values), do: []

  defp normalize_string(nil), do: ""
  defp normalize_string(value) when is_binary(value), do: String.trim(value)
  defp normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  defp normalize_string(value), do: value |> to_string() |> String.trim()

  defp map_get(map, key) when is_map(map) and is_atom(key), do: map_get(map, Atom.to_string(key))

  defp map_get(map, key) when is_map(map) and is_binary(key) do
    Enum.find_value(map, fn
      {existing_key, value} when is_binary(existing_key) and existing_key == key -> value
      {existing_key, value} when is_atom(existing_key) ->
        if Atom.to_string(existing_key) == key, do: value, else: nil
      _ ->
        nil
    end)
  end

  defp map_get(_map, _key), do: nil

  defp map_has_key?(map, key) do
    match?({:ok, _}, fetch_map(map, key))
  end

  defp fetch_map(map, key) do
    case map_get(map, key) do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end
end
