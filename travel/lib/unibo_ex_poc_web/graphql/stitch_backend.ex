defmodule UniboExPocWeb.Graphql.StitchBackend do
  @moduledoc """
  Stitch -> GraphQL backend adapter / runtime bridge（由 UniBO 自动生成）。

  目标：
  - 根据 frontend_manifest/pages[*].api_map 为 Stitch 页面解析 backend contract
  - 将 Stitch 的 __load__/event 调度翻译成 GraphQL query/mutation
  - 把 GraphQL 返回收口成 {:ok, %{dto, status, effects, errors, meta}} 约定
  """

  alias UniboExPocWeb.Graphql.RuntimeConfig
  alias UniboExPocWeb.GraphqlController

  @load_event "__load__"
  @default_selection "id"

  def contract(page_id) when is_binary(page_id) do
    with {:ok, page} <- page(page_id, %{}) do
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
         {:ok, page} <- page(page_id, state),
         {:ok, operation} <- resolve_operation(page, event, params, state),
         {:ok, query, variables} <- build_graphql_request(page, operation, params, state),
         {:ok, result} <- call_graphql(query, variables, state),
         {:ok, backend_result} <- normalize_backend_result(page, operation, event, params, result) do
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

  defp page(page_id, state) when is_binary(page_id) do
    embedded_page =
      state
      |> map_get("__compiled_backend_page")
      |> normalize_map()

    if normalize_string(map_get(embedded_page, "page_id")) == page_id do
      {:ok, embedded_page}
    else
      RuntimeConfig.frontend_backend_page(page_id)
    end
  end

  defp page(_page_id, _state), do: {:error, :stitch_backend_page_not_found}

  defp resolve_operation(page, event, params, state) do
    api_map = normalize_map(map_get(page, "api_map"))
    normalized_event = normalize_string(event)
    api_key =
      resolve_api_key(
        api_map,
        normalized_event,
        normalize_string(map_get(page, "page_kind")),
        params,
        state
      )

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

  defp resolve_api_key(api_map, event, page_kind, params, state) do
    normalized = normalize_string(event)
    stripped = String.replace_prefix(normalized, "action_", "")
    current_record_id =
      normalize_string(map_get(params, "id")) ||
        normalize_string(map_get(state, "id")) ||
        normalize_string(map_get(map_get(state, "record") || %{}, "id"))

    cond do
      normalized == @load_event and page_kind == "search" ->
        ""

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

      page_kind == "detail" and normalized == "form_submit" and current_record_id == "" and map_has_key?(api_map, "create") ->
        "create"

      page_kind == "detail" and normalized == "form_submit" and map_has_key?(api_map, "update") ->
        "update"

      page_kind == "detail" and current_record_id != "" and normalized == @load_event and map_has_key?(api_map, "get") ->
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
        resolved_type = resolve_input_type_name(input_type, field)
        input = sanitize_input_params(params) |> extract_entity_input() |> filter_input_by_schema(resolved_type) |> coerce_input_for_type(resolved_type)
        {decl, arg} = input_type_decl(input_type, field)

        {:ok,
         "mutation StitchCreate(#{decl}) { #{field}(#{arg}) { result { #{selection} } errors { message code } } }",
         %{"input" => input}}

      "update" ->
        id = resolve_id(params, state)
        resolved_type = resolve_input_type_name(input_type, field, "update")
        input = sanitize_input_params(params) |> Map.delete("id") |> extract_entity_input() |> filter_input_by_schema(resolved_type) |> coerce_input_for_type(resolved_type)
        {decl, arg} = input_type_decl(input_type, field)

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
        input = sanitize_input_params(params) |> Map.delete("id") |> filter_input_by_schema(input_type) |> coerce_input_for_type(input_type)
        {decl, arg} = input_type_decl(input_type, field)

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

  defp input_type_decl(input_type, _field) when input_type != "" do
    {"$input: #{input_type}!", "input: $input"}
  end

  defp input_type_decl(_input_type, field) when is_binary(field) and field != "" do
    # fallback: 从 field 名推导 input type（如 create_travel_travel_airline → CreateTravelTravelAirlineInput）
    inferred =
      field
      |> String.split("_")
      |> Enum.map(&String.capitalize/1)
      |> Enum.join()
      |> Kernel.<>("Input")

    {"$input: #{inferred}!", "input: $input"}
  end

  defp input_type_decl(_input_type, _field) do
    {"$input: JSON", "input: $input"}
  end

  # 解析 input type 名称（用于 filter_input_by_schema）
  defp resolve_input_type_name(input_type, _field) when is_binary(input_type) and input_type != "", do: input_type
  defp resolve_input_type_name(_input_type, field) when is_binary(field) and field != "" do
    field |> String.split("_") |> Enum.map(&String.capitalize/1) |> Enum.join() |> Kernel.<>("Input")
  end
  defp resolve_input_type_name(_, _), do: ""

  # update 变体：field 是 "update_xxx"，直接用
  defp resolve_input_type_name(input_type, field, _mode), do: resolve_input_type_name(input_type, field)

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

  defp normalize_backend_result(page, operation, event, params, result) when is_map(result) do
    field = normalize_string(map_get(operation, "field"))
    data = map_get(result, :data) || map_get(result, "data") || %{}
    top_level_errors = normalize_errors(map_get(result, :errors) || map_get(result, "errors") || [])
    raw_value = map_get(data, field)
    payload_errors = extract_payload_errors(raw_value)
    errors = top_level_errors ++ payload_errors
    value = extract_payload_result(raw_value)
    status = adapt_status(page, operation, value)
    dto = adapt_dto(page, operation, value)
    page_id = normalize_string(map_get(page, "page_id"))
    api_key = normalize_string(map_get(operation, "api_key"))
    page_kind = normalize_string(map_get(page, "page_kind"))
    explicit_effects =
      case UniboExPocWeb.Generated.PageHostRuntime.event_navigate_to(
             page_id,
             normalize_string(event),
             params
           ) do
        {:ok, to} when is_binary(to) and to != "" ->
          [%{type: "navigate", to: to}]

        _ ->
          []
      end

    effects =
      case explicit_effects do
        [] -> implicit_backend_effects(page, page_id, page_kind, api_key, params, value)
        value -> value
      end

    {:ok,
     %{}
     |> Map.put(:dto, dto)
     |> Map.put(:status, status)
     |> Map.put(:effects, effects)
      |> Map.put(:errors, errors)
     |> Map.put(:meta, %{"page_id" => page_id, "field" => field, "api_key" => api_key})}
  end

  defp normalize_backend_result(_page, _operation, _event, _params, _result), do: {:error, :stitch_backend_invalid_result}

  defp implicit_backend_effects(page, page_id, "detail", "create", params, value) do
    record_id = value |> extract_record() |> map_get("id") |> normalize_string()

    case record_id do
      "" ->
        []

      id ->
        route_params = params |> normalize_map() |> Map.put("id", id)
        target =
          case compiled_host_route_for_page(page, route_params) do
            "" -> UniboExPocWeb.Generated.PageHostRuntime.host_route_for_page(page_id, route_params)
            value -> value
          end

        [%{type: "navigate", to: target}]
    end
  end

  defp implicit_backend_effects(_page, _page_id, _page_kind, _api_key, _params, _value), do: []

  defp compiled_host_route_for_page(page, params) when is_map(page) and is_map(params) do
    route = page |> map_get("route") |> normalize_map()
    route_path = route |> map_get("path") |> normalize_string()
    route_query = route |> map_get("query") |> normalize_string()
    page_id = page |> map_get("page_id") |> normalize_string()

    case route_path do
      "" ->
        ""

      path ->
        rendered_path = interpolate_route_path(path, params)
        rendered_query = interpolate_route_query(route_query, params)
        target = if rendered_query == "", do: rendered_path, else: rendered_path <> "?" <> rendered_query
        UniboExPocWeb.Generated.PageHostRuntime.normalize_host_target(target, page_id)
    end
  end

  defp compiled_host_route_for_page(_page, _params), do: ""

  defp interpolate_route_path(path, params) when is_binary(path) and is_map(params) do
    Regex.replace(~r/:([a-zA-Z0-9_]+)/, path, fn _full, key ->
      normalize_string(Map.get(params, key, Map.get(params, String.to_atom(key), "")))
    end)
  end

  defp interpolate_route_path(path, _params), do: normalize_string(path)

  defp interpolate_route_query(query, params) when is_binary(query) and is_map(params) do
    Regex.replace(~r/\{\{\s*([^}]+?)\s*\}\}/, query, fn _full, key ->
      normalize_string(Map.get(params, String.trim(key), Map.get(params, String.to_atom(String.trim(key)), "")))
    end)
  end

  defp interpolate_route_query(query, _params), do: normalize_string(query)

  defp extract_payload_result(value) when is_map(value) do
    cond do
      map_has_key?(value, "result") -> map_get(value, "result")
      map_has_key?(value, :result) -> map_get(value, :result)
      true -> value
    end
  end

  defp extract_payload_result(value), do: value

  defp extract_payload_errors(value) when is_map(value) do
    normalize_errors(map_get(value, "errors") || map_get(value, :errors) || [])
  end

  defp extract_payload_errors(_value), do: []

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

    # 按 api_key 而非 page_kind 判断返回格式（#1681）
    case normalize_string(map_get(operation, "api_key")) do
      "list" ->
        rows = extract_rows(value)
        # 检查 defaults 中是否有集合变量名（如 records），用它替代硬编码 rows
        list_var = detect_list_variable(defaults)

        state
        |> Map.put(list_var, rows)
        |> Map.put(list_var <> "_empty", rows == [])
        |> Map.put("loading", false)

      _ ->
        record = extract_record(value)
        record_var = detect_record_variable(defaults)

        # 把实际数据设到所有 record-like key（值为 map 的 defaults key），
        # 避免 detect_record_variable 非确定性导致空默认值覆盖实际数据 (#2155)
        skip_keys = MapSet.new(["editing", "loading", "filter", "form", "rows", "rows_empty"])

        state =
          Enum.reduce(defaults, state, fn
            {key, default_val}, acc when is_map(default_val) and is_binary(key) ->
              if MapSet.member?(skip_keys, key), do: acc, else: Map.put(acc, key, record)

            _, acc ->
              acc
          end)

        state
        |> Map.put(record_var, record)
        |> Map.put("form", state["form"] || record)
        |> Map.put("loading", false)
    end
  end

  # 按 api_key 而非 page_kind 判断返回格式（#1681）
  defp adapt_dto(page, operation, value) do
    defaults =
      page
      |> map_get("state_schema")
      |> map_get("defaults")
      |> normalize_map()

    case normalize_string(map_get(operation, "api_key")) do
      "list" ->
        rows = extract_rows(value)
        # 检查 defaults 中是否有集合变量名（如 records），用它替代硬编码 rows
        list_var = detect_list_variable(defaults)
        %{list_var => rows, "raw" => value}

      _ ->
        record = extract_record(value)
        record_var = detect_record_variable(defaults)
        %{record_var => record, "raw" => value}
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

  # 从 state_schema defaults 中检测集合变量名（值为 list 的第一个 key）
  # 如 defaults 有 "records" => [...]，返回 "records"；没有则 fallback 到 "rows"
  defp detect_list_variable(defaults) when is_map(defaults) do
    Enum.find_value(defaults, "rows", fn
      {key, value} when is_list(value) and is_binary(key) -> key
      _ -> nil
    end)
  end

  defp detect_list_variable(_defaults), do: "rows"

  # 从 state_schema defaults 中检测单条记录变量名（值为 map 的第一个 key）
  # 如 defaults 有 "course" => %{}，返回 "course"；没有则 fallback 到 "record"
  defp detect_record_variable(defaults) when is_map(defaults) do
    skip_keys = MapSet.new(["editing", "loading", "filter", "form", "rows", "rows_empty"])
    Enum.find_value(defaults, "record", fn
      {key, value} when is_map(value) and is_binary(key) ->
        if MapSet.member?(skip_keys, key), do: nil, else: key
      _ -> nil
    end)
  end

  defp detect_record_variable(_defaults), do: "record"

  defp selection_set(page, _operation, state) do
    # 同时检查 string key 和 atom key，修复 PageHostRuntime 传入 :selection 的兼容问题（#1681）
    sel = map_get(state, "selection") || Map.get(state, :selection)
    resolved = sel |> normalize_string() |> case do
      "" -> build_selection_from_page(page)
      value -> value
    end
    require Logger
    Logger.debug("[selection_set] sel=#{inspect(sel)} resolved=#{resolved}")
    resolved
  end

  defp build_selection_from_page(page) do
    # 优先使用 backend.load.selection（完整的 GraphQL 字段映射）(#1812)
    backend_selection =
      page
      |> map_get("backend")
      |> normalize_map()
      |> map_get("load")
      |> normalize_map()
      |> map_get("selection")
      |> normalize_string()

    if backend_selection != "" do
      backend_selection
    else
      # fallback: 从 defaults 推导
      page
      |> map_get("state_schema")
      |> map_get("defaults")
      |> normalize_map()
      |> build_selection_from_defaults()
    end
  end

  defp build_selection_from_defaults(defaults) do
    rows = map_get(defaults, "rows")
    record = map_get(defaults, "record")
    form = map_get(defaults, "form")

    # 检测 defaults 中任意 list 类型的值（如 records），作为 rows 的 fallback
    any_list =
      Enum.find_value(defaults, nil, fn
        {_key, value} when is_list(value) and value != [] -> value
        _ -> nil
      end)

    sample =
      cond do
        is_list(rows) and match?([first | _] when is_map(first), rows) ->
          List.first(rows)

        is_list(any_list) and match?([first | _] when is_map(first), any_list) ->
          List.first(any_list)

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

  # 从嵌套 entity key 提取扁平参数。
  # 单个嵌套 map + 顶层标量参数时，将两者合并，保证表单字段与路由/上下文参数一起进入 input。
  defp extract_entity_input(params) when is_map(params) do
    nested_entries =
      Enum.filter(Map.to_list(params), fn
        {key, value} when is_binary(key) and is_map(value) -> true
        _ -> false
      end)

    case nested_entries do
      [{nested_key, nested_value}] ->
        scalar_params =
          params
          |> Map.delete(nested_key)
          |> Enum.reject(fn {_key, value} -> is_map(value) end)
          |> Map.new()

        Map.merge(nested_value, scalar_params)

      _ ->
        params
    end
  end

  defp extract_entity_input(params), do: params

  # 根据 Absinthe schema introspection 过滤 input 字段，只保留 input type 声明的字段
  defp filter_input_by_schema(input, input_type_name) when is_binary(input_type_name) and input_type_name != "" do
    # input_type_name 是 PascalCase（如 UpdateTravelTravelAirlineInput），转为 atom 查找
    type_id = input_type_name |> Macro.underscore() |> String.to_existing_atom()

    case Absinthe.Schema.lookup_type(RuntimeConfig.schema_module(), type_id) do
      %{fields: fields} when is_map(fields) ->
        accepted =
          fields
          |> Map.keys()
          |> Enum.flat_map(fn k ->
            s = to_string(k)
            # 同时接受 snake_case 原始 key 和 camelCase 变体
            [s, Macro.underscore(s)]
          end)
          |> MapSet.new()

        Map.filter(input, fn {k, _v} -> MapSet.member?(accepted, to_string(k)) end)

      _ -> input
    end
  rescue
    ArgumentError -> input
  end

  defp filter_input_by_schema(input, _), do: input

  # 根据 Absinthe schema introspection 将 HTML form 字符串值转换为 GraphQL 强类型
  defp coerce_input_for_type(input, type_name) when is_map(input) and is_binary(type_name) and type_name != "" do
    type_id = type_name |> Macro.underscore() |> String.to_existing_atom()

    case Absinthe.Schema.lookup_type(RuntimeConfig.schema_module(), type_id) do
      %{fields: fields} when is_map(fields) ->
        Map.new(input, fn {k, v} ->
          field_def = fields[String.to_existing_atom(k)] || fields[k |> Macro.camelize() |> String.to_existing_atom()]
          field_type = if field_def, do: unwrap_type(field_def.type), else: nil
          {k, coerce_value(v, field_type)}
        end)

      _ -> input
    end
  rescue
    ArgumentError -> input
  end

  defp coerce_input_for_type(input, _), do: input

  # 解包 Absinthe 嵌套 type（如 {:non_null, :integer} → :integer）
  defp unwrap_type({:non_null, inner}), do: unwrap_type(inner)
  defp unwrap_type({:list, inner}), do: unwrap_type(inner)
  defp unwrap_type(%Absinthe.Type.NonNull{of_type: inner}), do: unwrap_type(inner)
  defp unwrap_type(type), do: type

  defp coerce_value(v, :integer) when is_binary(v) and v != "" do
    case Integer.parse(v) do
      {int, _} -> int
      :error -> v
    end
  end

  defp coerce_value(v, :float) when is_binary(v) and v != "" do
    case Float.parse(v) do
      {float, _} -> float
      :error -> v
    end
  end

  defp coerce_value(v, :decimal) when is_binary(v), do: v
  defp coerce_value("true", :boolean), do: true
  defp coerce_value("false", :boolean), do: false
  defp coerce_value(v, _), do: v

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
