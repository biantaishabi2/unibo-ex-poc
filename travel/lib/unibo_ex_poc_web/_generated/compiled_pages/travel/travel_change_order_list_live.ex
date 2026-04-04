defmodule UniboExPocWeb.Pages.Travel.TravelChangeOrderListLive do
  @moduledoc """
  Auto-generated LiveView module.

  - Event names come from UI action semantics (events.schema).
  - Backend API names are placeholders by design; wire them to real services later.
  """

  use Phoenix.LiveView, layout: {UniboExPocWeb.Layouts, :app}

  import StitchUI.Components.Basic, except: [link: 1]
  import StitchUI.Components.Card
  import StitchUI.Components.Hero
  import StitchUI.Components.Feedback
  import StitchUI.Components.Forms
  import StitchUI.Components.Tabs
  import StitchUI.Components.Stepper
  import StitchUI.Components.Timeline
  import StitchUI.Components.Statistic
  import StitchUI.Components.Avatar
  import StitchUI.Components.Accordion
  import StitchUI.Components.Breadcrumb
  import StitchUI.Components.List
  import StitchUI.Components.Table
  import StitchUI.Components.Select
  import StitchUI.Components.Toggle
  import StitchUI.Components.ControlBar
  import StitchUI.Components.Tree
  import StitchUI.Layouts.Core

  @page_id "travel_change_order_list"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): rows, rows[], rows[].approval_mode, rows[].change_fee, rows[].change_reason, rows[].id, rows[].price_difference, rows[].status, rows_empty, travel_change_order, travel_change_order.page, travel_change_order.total_pages
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"travel_change_order\": {
    \"page\": \"\",
    \"total_pages\": \"\"
  },
  \"rows_empty\": true,
  \"rows\": [
    {
      \"id\": \"row_01\",
      \"change_reason\": \"\",
      \"price_difference\": \"\",
      \"change_fee\": \"\",
      \"status\": \"\",
      \"approval_mode\": \"\"
    },
    {
      \"id\": \"row_02\",
      \"change_reason\": \"\",
      \"price_difference\": \"\",
      \"change_fee\": \"\",
      \"status\": \"\",
      \"approval_mode\": \"\"
    },
    {
      \"id\": \"row_03\",
      \"change_reason\": \"\",
      \"price_difference\": \"\",
      \"change_fee\": \"\",
      \"status\": \"\",
      \"approval_mode\": \"\"
    }
  ]
}")
  # NOTE: we atomize at runtime (mount/3) and store the result in assigns.__status_defaults.

  # Backend dispatch contract (Layer-2 behavior): mode + API placeholders.
  @backend_mode "api"
  # compiled 模式：直连 GraphQL，不再经过 StitchBackend
  @runtime_config_mod UniboExPocWeb.Graphql.RuntimeConfig
  @backend_load_event "list"
  @backend_load_selection "approval_mode: approvalMode change_fee: changeFee change_reason: changeReason id new_offer_id: newOfferId price_difference: priceDifference status tenant_id: tenantId"
  @backend_load_assigns %{}
  @backend_params_accept ["status", "approval_mode"]
  @backend_info_reload_messages []
  @backend_api_map %{
    "list" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelChangeOrder.list"}
  }
  @graphql_field_map %{"list" => "list_travel_travel_change_orders"}
  @input_allowlist %{}
  @input_type_name_map %{}
  @entity_assign_fields []
  @status_key_roots [:rows, :rows_empty, :filter, :loading]
  @auth_mode "optional"
  @user_context_assigns []

  @impl true
  def mount(params, _session, socket) do
    socket = ensure_user_context(socket)
    socket = __assign_tenant_context(socket, params)
    socket = assign(socket, :page_title, @page_title)
    defaults = atomize_keys(@status_defaults_raw)
    socket = assign(socket, defaults)
    socket = assign(socket, :__status_defaults, defaults)
    socket = if is_map(@backend_load_assigns) and map_size(@backend_load_assigns) > 0, do: assign(socket, @backend_load_assigns), else: socket
    socket = apply_derived(socket)
    socket = apply_params(socket, params)
    backend_params = params |> __filter_backend_params() |> __inject_backend_tenant(socket)
    socket = assign(socket, :__backend_params, backend_params)
    is_new_mode = socket.assigns.live_action == :new or Map.get(params, "id") == "new"
    socket = if is_new_mode, do: assign(socket, editing: true), else: socket
    socket = if @backend_mode == "api" and is_binary(@backend_load_event) and not is_new_mode, do: dispatch_backend(@backend_load_event, Map.put(backend_params, "__page_id", @page_id), socket), else: socket
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = __maybe_assign_self_path(socket, _uri)
    socket = __assign_tenant_context(socket, params)
    backend_params = params |> __filter_backend_params() |> __inject_backend_tenant(socket)
    socket = assign(socket, :__backend_params, backend_params)
    is_new_mode = socket.assigns.live_action == :new or Map.get(params, "id") == "new"
    socket = if is_new_mode and not Map.get(socket.assigns, :editing, false), do: assign(socket, editing: true), else: socket
    {:noreply, apply_params(socket, params)}
  end

  @impl true
  def handle_info(msg, socket) do
    # compiled + graphql 模式：handle_info 不转发给 StitchBackend
    _ = msg
    {:noreply, socket}
  end

  @impl true
  def handle_event("filter_submit", params, socket) do
    # UI action event name: filter_submit
    socket = dispatch_backend("filter_submit", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("navigate_create", params, socket) do
    # UI action event name: navigate_create
    socket = dispatch_backend("navigate_create", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("row_click", params, socket) do
    # UI action event name: row_click
    socket = dispatch_backend("row_click", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("travel_change_order_page_next", params, socket) do
    # UI action event name: travel_change_order_page_next
    socket = dispatch_backend("travel_change_order_page_next", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("travel_change_order_page_prev", params, socket) do
    # UI action event name: travel_change_order_page_prev
    socket = dispatch_backend("travel_change_order_page_prev", params, socket)
    {:noreply, socket}
  end

  defp apply_params(socket, params) when is_map(params) do
    socket
  end

  defp __filter_backend_params(params) when is_map(params) do
    if @backend_params_accept == [] do
      params
    else
      Map.take(params, @backend_params_accept ++ ["__page_id"])
    end
  end
  defp __filter_backend_params(params), do: params

  defp __inject_backend_tenant(params, socket) when is_map(params) do
    case Map.get(socket.assigns, :tenant_id) do
      nil -> params
      tenant_id -> Map.put_new(params, "tenant_id", tenant_id)
    end
  end
  defp __inject_backend_tenant(params, _socket), do: params

  defp __merge_backend_params(params, socket) when is_map(params) do
    base = Map.get(socket.assigns, :__backend_params, %{})
    merged = if is_map(base), do: Map.merge(base, params), else: params
    __inject_backend_tenant(merged, socket)
  end
  defp __merge_backend_params(_params, socket) do
    base = Map.get(socket.assigns, :__backend_params, %{})
    merged = if is_map(base), do: base, else: %{}
    __inject_backend_tenant(merged, socket)
  end

  defp __accept_backend_info?({kind, value}) when is_atom(kind) and is_binary(value) do
    kind == :page_host_reload and value in @backend_info_reload_messages
  end
  defp __accept_backend_info?(value) when is_binary(value), do: value in @backend_info_reload_messages
  defp __accept_backend_info?(_), do: @backend_info_reload_messages == []

  defp ensure_user_context(socket) do
    # Thin user-context contract: keep it uniform so skeletons stay generated and diffable.
    #
    # - auth_mode is a placeholder; real auth should live in plugs/on_mount hooks.
    # - assign_new keeps the controller thin and avoids hard-coding session shape here.
    _ = @auth_mode
    Enum.reduce(@user_context_assigns, socket, fn key, s ->
      assign_new(s, key, fn -> nil end)
    end)
  end

  defp __assign_tenant_context(socket, params) when is_map(params) do
    tenant_id =
      Map.get(params, "tenant_id") ||
        Map.get(socket.assigns, :tenant_id) ||
        __default_tenant_id()

    if is_binary(tenant_id) and String.trim(tenant_id) != "" do
      assign(socket, :tenant_id, String.trim(tenant_id))
    else
      socket
    end
  end
  defp __assign_tenant_context(socket, _params), do: socket

  defp __default_tenant_id do
    if Code.ensure_loaded?(@runtime_config_mod) and function_exported?(@runtime_config_mod, :default_tenant_id, 0) do
      @runtime_config_mod.default_tenant_id()
    else
      nil
    end
  end

  defp __maybe_assign_self_path(socket, uri) when is_binary(uri) do
    path = URI.parse(uri).path
    if is_binary(path) and String.starts_with?(path, "/") do
      assign(socket, :self_path, path)
    else
      socket
    end
  end
  defp __maybe_assign_self_path(socket, _), do: socket

  defp atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {k, v}, acc ->
      key =
        cond do
          is_binary(k) ->
            try do
              String.to_existing_atom(k)
            rescue
              _ -> String.to_atom(k)
            end
          true ->
            k
        end
      Map.put(acc, key, atomize_keys(v))
    end)
  end
  defp atomize_keys(value) when is_list(value), do: Enum.map(value, &atomize_keys/1)
  defp atomize_keys(value), do: value

  defp __take_status(assigns) when is_map(assigns) do
    st = Map.take(assigns, @status_key_roots)
    defaults = Map.get(assigns, :__status_defaults, %{})
    Map.put(st, :__status_defaults, defaults)
  end
  defp __take_status(_), do: %{}

  defp dispatch_backend(event, params, socket) do
    params = params |> __merge_backend_params(socket) |> __inject_backend_id(socket) |> Map.put("__page_id", @page_id)
    state0 = __take_status(socket.assigns)
    state0 = __inject_backend_tenant(state0, socket)
    result =
      case @backend_mode do
        "transitions" ->
          %{assigns: assigns2, effects: effects} = __apply_transitions(event, params, state0)
          {dto, st} = __split_dto_status(assigns2)
          {:ok, %{dto: dto, status: st, effects: effects, errors: [], meta: %{mode: "transitions"}}}
        "api" ->
          %{effects: local_effects} = __apply_transitions(event, params, state0)
          backend_api = __resolve_backend_api(event, socket)
          case backend_api do
            nil ->
              %{assigns: assigns2, effects: effects} = __apply_transitions(event, params, state0)
              {dto, st} = __split_dto_status(assigns2)
              {:ok, %{dto: dto, status: st, effects: effects, errors: [], meta: %{mode: "api_local_transition"}}}
            _mapping ->
              backend_result = __compiled_graphql_dispatch(event, params, socket)
              # 合并本地 transition effects
              case {backend_result, local_effects} do
                {{:ok, %{} = data}, [_ | _]} ->
                  existing = Map.get(data, :effects, [])
                  {:ok, Map.put(data, :effects, existing ++ local_effects)}
                _ ->
                  backend_result
              end
          end
      end
    result = __maybe_inject_destroy_redirect(event, result, socket)
    apply_backend_result(socket, result)
  end

  defp __compiled_graphql_dispatch(event, params, socket) do
    action = __extract_compiled_action(event, socket)
    graphql_field = Map.get(@graphql_field_map, action)
    unless graphql_field do
      {:ok, %{dto: %{}, status: %{}, effects: [], errors: [%{message: "no graphql_field for #{action}"}], meta: %{}}}
    else
      {query, variables} = __build_compiled_query(action, graphql_field, params, socket)
      __exec_compiled_graphql(query, variables, socket)
    end
  end

  defp __extract_compiled_action(event, socket) do
    normalized = to_string(event) |> String.replace_prefix("action_", "")
    case normalized do
      "form_submit" ->
        record_id = get_in(socket.assigns, [:record, :id]) || get_in(socket.assigns, [:record, "id"]) ||
          get_in(socket.assigns, [:record, :id]) || get_in(socket.assigns, [:record, "id"])
        is_new = socket.assigns.live_action == :new or record_id in [nil, ""]
        if is_new, do: "create", else: "update"
      other -> other
    end
  end

  defp __build_compiled_query(action, field, params, socket) do
    selection = @backend_load_selection || "id"
    case action do
      "list" ->
        {~s|query { #{field} { results { #{selection} } count } }|, %{}}
      "get" ->
        id = __resolve_compiled_id(params, socket)
        {~s|query($id: ID!) { #{field}(id: $id) { #{selection} } }|, %{"id" => id}}
      action when action in ["create", "update"] ->
        id = __resolve_compiled_id(params, socket)
        input = __process_compiled_input(action, params)
        input_type = Map.get(@input_type_name_map, action, "JSON")
        if id && action == "update" do
          {~s|mutation($id: ID!, $input: #{input_type}!) { #{field}(id: $id, input: $input) { result { #{selection} } errors { message } } }|, %{"id" => id, "input" => input}}
        else
          {~s|mutation($input: #{input_type}!) { #{field}(input: $input) { result { #{selection} } errors { message } } }|, %{"input" => input}}
        end
      "destroy" ->
        id = __resolve_compiled_id(params, socket)
        {~s|mutation($id: ID!) { #{field}(id: $id) { result { id } errors { message } } }|, %{"id" => id}}
      _ ->
        # 自定义 action（activate, deactivate 等）
        id = __resolve_compiled_id(params, socket)
        {~s|mutation($id: ID!) { #{field}(id: $id) { result { #{selection} } errors { message } } }|, %{"id" => id}}
    end
  end

  defp __process_compiled_input(action, params) do
    allowlist = Map.get(@input_allowlist, action, [])
    params
    |> Map.drop(["id", :id, "_target", "__page_id", "_csrf_token"])
    |> __extract_compiled_entity_input()
    |> Map.take(allowlist)
    |> __to_camel_keys()
  end

  defp __extract_compiled_entity_input(params) when is_map(params) do
    nested = Enum.filter(params, fn {k, v} -> is_binary(k) and is_map(v) end)
    case nested do
      [{_key, nested_value}] ->
        scalar = Map.reject(params, fn {_k, v} -> is_map(v) end)
        Map.merge(nested_value, scalar)
      _ -> params
    end
  end
  defp __extract_compiled_entity_input(params), do: params

  defp __resolve_compiled_id(params, socket) do
    Map.get(params, "id") ||
      Map.get(params, :id) ||
      get_in(socket.assigns, [:record, :id]) ||
      get_in(socket.assigns, [:record, "id"]) ||
      get_in(socket.assigns, [:record, :id]) ||
      get_in(socket.assigns, [:record, "id"]) ||
      (socket.assigns[:record] && socket.assigns[:record]["id"]) ||
      (socket.assigns[:record] && socket.assigns[:record]["id"]) || ""
  end

  defp __to_camel_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {__camelize_key(to_string(k)), v} end)
  end
  defp __to_camel_keys(other), do: other

  defp __camelize_key(s) do
    [first | rest] = String.split(s, "_")
    first <> Enum.map_join(rest, "", &String.capitalize/1)
  end

  defp __exec_compiled_graphql(query, variables, socket) when is_binary(query) do
    tenant_id = Map.get(socket.assigns, :tenant_id) ||
      (if function_exported?(@runtime_config_mod, :default_tenant_id, 0), do: @runtime_config_mod.default_tenant_id(), else: nil)

    base_context = %{
      actor: Map.get(socket.assigns, :actor),
      current_user: Map.get(socket.assigns, :current_user),
      auth_claims: Map.get(socket.assigns, :auth_claims),
      tenant_id: tenant_id,
      tenant: Map.get(socket.assigns, :tenant) || tenant_id,
      context_envelope: Map.get(socket.assigns, :context_envelope)
    }

    context = if function_exported?(@runtime_config_mod, :build_context, 1) do
      @runtime_config_mod.build_context(base_context)
    else
      base_context
    end

    loader = if Code.ensure_loaded?(Dataloader) do
      if function_exported?(@runtime_config_mod, :new_loader, 1),
        do: @runtime_config_mod.new_loader(context),
        else: Dataloader.new()
    end
    context = if loader, do: Map.put(context, :loader, loader), else: context

    schema_mod = if function_exported?(@runtime_config_mod, :schema_module, 0),
      do: @runtime_config_mod.schema_module(),
      else: nil

    if schema_mod do
      case Absinthe.run(query, schema_mod, variables: variables, context: context) do
        {:ok, %{data: data}} when is_map(data) ->
          field_result = data |> Map.values() |> Enum.find(& &1) || %{}
          case field_result do
            %{"results" => results, "count" => count} ->
              {:ok, %{dto: %{results: results, count: count}, status: %{}, effects: [], errors: [], meta: %{mode: "compiled_graphql"}}}
            %{"result" => result, "errors" => errors} when is_list(errors) and length(errors) > 0 ->
              {:error, %{errors: errors, meta: %{mode: "compiled_graphql"}}}
            %{"result" => result} ->
              {:ok, %{dto: result || %{}, status: %{}, effects: [], errors: [], meta: %{mode: "compiled_graphql"}}}
            single when is_map(single) ->
              {:ok, %{dto: single, status: %{}, effects: [], errors: [], meta: %{mode: "compiled_graphql"}}}
            _ ->
              {:ok, %{dto: %{}, status: %{}, effects: [], errors: [], meta: %{mode: "compiled_graphql"}}}
          end
        {:ok, %{errors: errors}} ->
          {:error, %{errors: errors, meta: %{mode: "compiled_graphql"}}}
        {:error, reason} ->
          {:error, %{errors: [%{message: inspect(reason)}], meta: %{mode: "compiled_graphql"}}}
      end
    else
      {:error, %{errors: [%{message: "schema module not available"}], meta: %{}}}
    end
  end

  defp __resolve_backend_api(event, socket) do
    normalized = to_string(event)
    direct = Map.get(@backend_api_map, normalized) || Map.get(@backend_api_map, String.replace_prefix(normalized, "action_", ""))
    case direct do
      nil ->
        is_new_mode = socket.assigns.live_action == :new or get_in(socket.assigns, [:record, :id]) in [nil, ""]
        cond do
          normalized == "form_submit" and is_new_mode -> Map.get(@backend_api_map, "create")
          normalized == "form_submit" -> Map.get(@backend_api_map, "update")
          true -> nil
        end
      mapping ->
        mapping
    end
  end

  defp __inject_backend_id(params, socket) when is_map(params) do
    has_id = Map.has_key?(params, "id") or Map.has_key?(params, :id)
    if has_id do
      params
    else
      id =
        Map.get(params, "id") ||
          Map.get(params, :id) ||
          get_in(socket.assigns, [:record, :id]) ||
          get_in(socket.assigns, [:record, "id"]) ||
          get_in(socket.assigns, [:null, :id]) ||
          get_in(socket.assigns, [:null, "id"])
      case id do
        value when is_binary(value) and value != "" -> Map.put(params, "id", value)
        _ -> params
      end
    end
  end
  defp __inject_backend_id(params, _socket), do: params

  defp __maybe_inject_destroy_redirect(event, {:ok, %{} = data} = result, socket) do
    normalized = to_string(event)
    is_destroy = normalized == "action_destroy" or String.ends_with?(normalized, "_destroy")
    existing_effects = Map.get(data, :effects, [])
    has_navigate = Enum.any?(existing_effects, fn
      %{type: "navigate"} -> true
      %{"type" => "navigate"} -> true
      _ -> false
    end)
    if is_destroy and not has_navigate do
      list_path = case Map.get(socket.assigns, :self_path) do
        p when is_binary(p) and p != "" ->
          # 去掉最后一段 path segment（/:id 的实际值）得到 list 页路径
          String.replace(p, ~r"/[^/]+$", "")
        _ -> nil
      end
      if is_binary(list_path) and list_path != "" do
        effects = existing_effects ++ [%{type: "navigate", to: list_path}]
        {:ok, Map.put(data, :effects, effects)}
      else
        result
      end
    else
      result
    end
  end
  defp __maybe_inject_destroy_redirect(_event, result, _socket), do: result

  defp __split_dto_status(assigns) when is_map(assigns) do
    # Split is a hint only. Both dto/status are still assigned as flat keys.
    if @status_key_roots == [] do
      {assigns, %{}}
    else
      status = Map.take(assigns, @status_key_roots)
      dto = Map.drop(assigns, @status_key_roots)
      {dto, status}
    end
  end

  defp apply_backend_result(socket, {:ok, %{dto: dto, status: st} = result}) when is_map(dto) and is_map(st) do
    effects = Map.get(result, :effects, [])
    errors = Map.get(result, :errors, [])
    meta = Map.get(result, :meta, %{})

    dto = atomize_keys(dto)
    st = atomize_keys(st)
    socket = socket |> assign(dto) |> assign(st)
    socket = assign(socket, :errors, errors)
    socket = assign(socket, :_dto, dto)
    socket = assign(socket, :_status, st)
    socket = assign(socket, :_effects, effects)
    socket = assign(socket, :_errors, errors)
    socket = assign(socket, :_meta, meta)
    socket = apply_derived(socket)
    apply_effects(socket, effects)
  end
  defp apply_backend_result(socket, {:ok, assigns}) when is_map(assigns) do
    # Backward compat: treat {:ok, assigns} as dto-only.
    assigns = atomize_keys(assigns)
    socket = socket |> assign(assigns)
    socket |> assign(:_dto, assigns) |> assign(:_status, %{})
  end
  defp apply_backend_result(socket, {:error, reason}) do
    assign(socket, :error, inspect(reason))
  end
  defp apply_backend_result(socket, other) do
    assign(socket, :error, "Invalid backend return: #{inspect(other)}")
  end

  defp apply_effects(socket, effects) when is_list(effects) do
    Enum.reduce(effects, socket, fn effect, s ->
      case effect do
        %{type: "patch", to: to} when is_binary(to) ->
          base = Map.get(s.assigns, :self_path)
          to2 = __normalize_to(base, to)
          if is_binary(to2), do: push_patch(s, to: to2), else: s
        %{type: "navigate", to: to} when is_binary(to) ->
          base = Map.get(s.assigns, :self_path)
          to2 = __normalize_to(base, to)
          if is_binary(to2), do: push_navigate(s, to: to2), else: s
        %{type: "flash", kind: kind, message: msg} when is_binary(kind) and is_binary(msg) -> put_flash(s, String.to_atom(kind), msg)
        _ -> s
      end
    end)
  end
  defp apply_effects(socket, _), do: socket

  defp __normalize_to(base, to) when is_binary(to) do
    to = String.trim(to)
    base = if is_binary(base), do: String.trim(base), else: nil

    cond do
      String.starts_with?(to, "/") -> to
      String.starts_with?(to, "?") and is_binary(base) and String.starts_with?(base, "/") -> base <> to
      String.starts_with?(to, "./") and is_binary(base) and String.starts_with?(base, "/") -> base <> "/" <> String.trim_leading(to, "./")
      (to != "") and is_binary(base) and String.starts_with?(base, "/") -> base <> "/" <> to
      true -> nil
    end
  end
  defp __normalize_to(_base, _to), do: nil

  defp apply_derived(socket), do: socket

  defp __lookup_param(params, key) when is_map(params) and is_binary(key) do
    cond do
      Map.has_key?(params, key) -> params[key]
      true ->
        Enum.find_value(params, fn
          {_k, %{} = v} -> Map.get(v, key)
          _ -> nil
        end)
    end
  end
  
  defp __lookup_param(_params, _key), do: nil
  
  defp __put_in_path(map, keys, value) when is_map(map) and is_list(keys) do
    put_in(map, Enum.map(keys, &Access.key(&1, %{})), value)
  end
  
  defp __update_in_path(map, keys, fun) when is_map(map) and is_list(keys) and is_function(fun, 1) do
    update_in(map, Enum.map(keys, &Access.key(&1, %{})), fun)
  end
  
  defp __interpolate_effects(effects, params) when is_list(effects) and is_map(params) do
    Enum.map(effects, fn
      %{to: to} = eff when is_binary(to) -> %{eff | to: __interpolate_to(to, params)}
      eff -> eff
    end)
  end
  defp __interpolate_effects(effects, _params), do: effects
  
  defp __interpolate_to(to, params) when is_binary(to) and is_map(params) do
    Regex.replace(~r/{{([^}]+)}}/, to, fn _, key ->
      v = __lookup_param(params, key)
      v = if is_list(v), do: List.first(v), else: v
      cond do
        v == nil -> ""
        v === true -> "true"
        v === false -> "false"
        true -> to_string(v)
      end
    end)
  end
  defp __interpolate_to(to, _params), do: to

  def __dispatch_transitions(event, params, assigns), do: __apply_transitions(event, params, assigns)

  defp __apply_transitions("filter_submit", params, assigns) do
  assigns = assigns
  effects = []
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions("navigate_create", params, assigns) do
  assigns = assigns
  effects = []
  effects = [%{to: "/pages/travel/travel_change_order/new", type: "navigate"} | effects]
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions(_event, _params, assigns), do: %{assigns: assigns, effects: []}

  def render(assigns) do
    ~H"""
    <.page title="列表" id="travel_change_order_list">
      <.section layout="none" id="header">
        <.flex justify="between" align="center" direction="row" id="header_bar">
          <.stack direction="column" id="page_meta">
            <.text variant="caption" color="muted" id="breadcrumb">
              TravelChangeOrder
            </.text>
            <.text variant="h1" id="page_title">
              改签单,记录针对已有 TravelOrder 的改签请求、差价与审批状态;审批通过 overlay on Approvals 域
            </.text>
          </.stack>
          <.button variant="primary" phx-click="navigate_create" size="md" id="create_btn">
            新建
          </.button>
        </.flex>
      </.section>
      <.section layout="none" id="view_tabs">
        <.tabs default_value="all" id="view_selector">
          <.tabs_list id="view_tab_list">
            <.tabs_trigger value="all" active_value="all" id="trigger_all">
              全部
            </.tabs_trigger>
          </.tabs_list>
        </.tabs>
      </.section>
      <.section layout="none" id="filter_section">
        <.card variant="default" id="filter_card">
          <.card_content id="filter_content">
            <.flex gap={4} align="center" direction="row" id="filter_row">
              <.stack direction="column" id="filter_fields" />
              <.button variant="secondary" phx-click="filter_submit" size="md" id="filter_submit">
                查询
              </.button>
            </.flex>
          </.card_content>
        </.card>
      </.section>
      <.section layout="none" id="table_section">
        <.table id="data_table">
          <.table_header id="data_header">
            <.table_row id="header_row">
              <.table_head id="th_change_reason">
                改签原因
              </.table_head>
              <.table_head id="th_price_difference">
                差价
              </.table_head>
              <.table_head id="th_change_fee">
                改签手续费
              </.table_head>
              <.table_head id="th_status">
                status
              </.table_head>
              <.table_head id="th_approval_mode">
                审批模式快照;none 表示跳过审批,self/oa 表示进入审批流
              </.table_head>
            </.table_row>
          </.table_header>
          <.table_body id="data_body">
            <%= for {row, idx} <- Enum.with_index((@rows || [])) do %>
              <.table_row phx-click="row_click" phx-value-id={row.id} id="travel_change_order_row">
                <.table_cell id="td_change_reason">
                  <%= get_in(row, [:change_reason]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.table_cell>
                <.table_cell id="td_price_difference">
                  <%= get_in(row, [:price_difference]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.table_cell>
                <.table_cell id="td_change_fee">
                  <%= get_in(row, [:change_fee]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.table_cell>
                <.table_cell id="td_status">
                  <%= if (val = get_in(row, [:status])) && to_string(val) != "" do %>
                    <.badge variant="default" size="sm" id="badge_status">
                      <%= to_string(val) %>
                    </.badge>
                  <% end %>
                </.table_cell>
                <.table_cell id="td_approval_mode">
                  <%= if (val = get_in(row, [:approval_mode])) && to_string(val) != "" do %>
                    <.badge variant="default" size="sm" id="badge_approval_mode">
                      <%= to_string(val) %>
                    </.badge>
                  <% end %>
                </.table_cell>
              </.table_row>
            <% end %>
          </.table_body>
        </.table>
      </.section>
      <.section layout="none" id="empty_section">
        <%= if (@rows_empty && @rows_empty != []) do %>
          <.empty_state description="暂无数据" id="no_data" />
        <% end %>
      </.section>
      <.section layout="none" id="footer">
        <.flex gap={2} direction="row" justify="center" id="pagination_bar">
          <.button phx-click="travel_change_order_page_prev" variant="primary" size="md" id="page_prev">
            上一页
          </.button>
          <.text id="page_info">
            <%= get_in(@travel_change_order, [:page]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %> / <%= get_in(@travel_change_order, [:total_pages]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
          </.text>
          <.button phx-click="travel_change_order_page_next" variant="primary" size="md" id="page_next">
            下一页
          </.button>
        </.flex>
      </.section>
    </.page>
    """
  end
end
