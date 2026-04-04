defmodule UniboExPocWeb.Pages.Travel.FlightDetailLive do
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

  @page_id "flight_detail"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): editing, flight_offer, flight_offer.arrival_airport_code, flight_offer.arrival_at, flight_offer.baggage_policy, flight_offer.cabin_class, flight_offer.currency, flight_offer.departure_airport_code, flight_offer.departure_at, flight_offer.fare_family, flight_offer.flight_no, flight_offer.itinerary_code, flight_offer.listed_price, flight_offer.refund_change_policy, flight_offer.sale_status, flight_offer.seats_available, flight_offer.settlement_price, flight_offer.supplier_code, record, record.sale_status
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"record\": {
    \"sale_status\": true
  },
  \"flight_offer\": {
    \"supplier_code\": \"\",
    \"itinerary_code\": \"\",
    \"flight_no\": \"\",
    \"departure_airport_code\": \"\",
    \"arrival_airport_code\": \"\",
    \"departure_at\": \"\",
    \"arrival_at\": \"\",
    \"cabin_class\": \"\",
    \"fare_family\": \"\",
    \"listed_price\": \"\",
    \"settlement_price\": \"\",
    \"currency\": \"\",
    \"seats_available\": \"\",
    \"baggage_policy\": \"\",
    \"refund_change_policy\": \"\",
    \"sale_status\": \"\"
  },
  \"editing\": false
}")
  # NOTE: we atomize at runtime (mount/3) and store the result in assigns.__status_defaults.

  # Backend dispatch contract (Layer-2 behavior): mode + API placeholders.
  @backend_mode "api"
  # compiled 模式：直连 GraphQL，不再经过 StitchBackend
  @runtime_config_mod UniboExPocWeb.Graphql.RuntimeConfig
  @backend_load_event "get"
  @backend_load_selection "id"
  @backend_load_assigns %{flight_offer: %{}}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{
    "get" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.FlightOffer.get"},
    "list" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.FlightOffer.list"}
  }
  @graphql_field_map %{"get" => "get_travel_flight_offer", "list" => "list_travel_flight_offers"}
  @input_allowlist %{}
  @input_type_name_map %{}
  @entity_assign_fields ["supplier_code", "itinerary_code", "flight_no", "departure_airport_code", "arrival_airport_code", "departure_at", "arrival_at", "cabin_class", "fare_family", "listed_price", "settlement_price", "currency", "seats_available", "baggage_policy", "refund_change_policy", "sale_status"]
  @status_key_roots []
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
  def handle_event("action_activate", params, socket) do
    # UI action event name: action_activate
    socket = dispatch_backend("action_activate", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_deactivate", params, socket) do
    # UI action event name: action_deactivate
    socket = dispatch_backend("action_deactivate", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_destroy", params, socket) do
    # UI action event name: action_destroy
    socket = dispatch_backend("action_destroy", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_expire", params, socket) do
    # UI action event name: action_expire
    socket = dispatch_backend("action_expire", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_edit", params, socket) do
    # UI action event name: cancel_edit
    socket = dispatch_backend("cancel_edit", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("form_change", params, socket) do
    # UI action event name: form_change
    socket = dispatch_backend("form_change", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("form_submit", params, socket) do
    # UI action event name: form_submit
    socket = dispatch_backend("form_submit", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_edit", params, socket) do
    # UI action event name: toggle_edit
    socket = dispatch_backend("toggle_edit", params, socket)
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
          get_in(socket.assigns, [:flight_offer, :id]) || get_in(socket.assigns, [:flight_offer, "id"])
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
      get_in(socket.assigns, [:flight_offer, :id]) ||
      get_in(socket.assigns, [:flight_offer, "id"]) ||
      (socket.assigns[:record] && socket.assigns[:record]["id"]) ||
      (socket.assigns[:flight_offer] && socket.assigns[:flight_offer]["id"]) || ""
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
          get_in(socket.assigns, [:flight_offer, :id]) ||
          get_in(socket.assigns, [:flight_offer, "id"])
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
    socket = __sync_entity_assign(socket, dto)
    socket = __sync_record_alias(socket)
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
    socket = __sync_entity_assign(socket, assigns)
    socket = __sync_record_alias(socket)
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

  defp __sync_entity_assign(socket, dto) when is_map(dto) do
    case dto do
      %{flight_offer: entity} when is_map(entity) and map_size(entity) > 0 -> assign(socket, :flight_offer, entity)
      %{record: entity} when is_map(entity) ->
        case __assign_map_present?(entity) do
          true -> assign(socket, :flight_offer, entity)
          false -> socket
        end
      _ ->
        source =
          Enum.reduce(["id" | @entity_assign_fields], %{}, fn key, acc ->
            case Map.fetch(dto, key) do
              {:ok, value} -> Map.put(acc, key, value)
              :error ->
                atom_key = if is_binary(key), do: String.to_atom(key), else: key
                case Map.fetch(dto, atom_key) do
                  {:ok, value} -> Map.put(acc, key, value)
                  :error -> acc
                end
            end
          end)
        if map_size(source) == 0 do
          socket
        else
          entity = Map.get(socket.assigns, :flight_offer, %{})
          entity = if is_map(entity), do: Map.merge(entity, source), else: source
          assign(socket, :flight_offer, entity)
        end
    end
  end
  defp __sync_entity_assign(socket, _dto), do: socket

  defp __sync_record_alias(socket) do
    case socket.assigns do
      %{flight_offer: entity} when is_map(entity) ->
        case __assign_map_present?(entity) do
          true -> assign(socket, :record, entity)
          false -> socket
        end
      _ -> socket
    end
  end

  defp __assign_map_present?(value) when is_map(value) do
    Enum.any?(value, fn
      {_key, nested} when is_map(nested) -> __assign_map_present?(nested)
      {_key, nested} when is_list(nested) -> nested != []
      {_key, nested} when is_binary(nested) -> String.trim(nested) != ""
      {_key, nil} -> false
      {_key, _nested} -> true
    end)
  end
  defp __assign_map_present?(_value), do: false

  defp apply_derived(socket), do: socket

  defp __apply_transitions(_event, _params, assigns), do: %{assigns: assigns, effects: []}

  def render(assigns) do
    ~H"""
    <.page title="详情" id="flight_detail">
      <.section layout="none" id="breadcrumb_section">
        <.breadcrumb id="page_breadcrumb">
          <.breadcrumb_list id="bc_list">
            <.breadcrumb_item id="bc_list_item">
              <.breadcrumb_link id="bc_link">
                列表
              </.breadcrumb_link>
            </.breadcrumb_item>
            <.breadcrumb_separator id="bc_sep" />
            <.breadcrumb_item id="bc_current_item">
              <.breadcrumb_page id="bc_current">
                详情
              </.breadcrumb_page>
            </.breadcrumb_item>
          </.breadcrumb_list>
        </.breadcrumb>
      </.section>
      <.section direction="row" justify="between" align="center" layout="grid" columns={2} id="detail_header">
        <.flex gap={3} align="center" direction="row" id="title_group">
          <.stack direction="column" id="title_meta">
            <.text variant="caption" color="muted" id="breadcrumb">
              FlightOffer
            </.text>
            <.text variant="h1" id="page_title">
              机票可售 offer,承载航班、舱位、票规和库存快照
            </.text>
          </.stack>
          <.badge bind="flight_offer.status" variant="default" size="sm" id="status_badge" />
        </.flex>
        <.flex gap={2} direction="row" id="actions_group">
          <.button variant="secondary" phx-click="toggle_edit" size="md" id="edit_btn">
            编辑
          </.button>
          <%= if get_in(@record, [:sale_status]) == "draft" || get_in(@record, [:sale_status]) == "inactive" do %>
            <.button variant="secondary" phx-click="action_activate" size="md" id="flight_offer_action_activate">
              activate
            </.button>
          <% end %>
          <%= if get_in(@record, [:sale_status]) == "active" do %>
            <.button variant="secondary" phx-click="action_deactivate" size="md" id="flight_offer_action_deactivate">
              deactivate
            </.button>
          <% end %>
          <%= if get_in(@record, [:sale_status]) == "active" do %>
            <.button variant="secondary" phx-click="action_expire" size="md" id="flight_offer_action_expire">
              expire
            </.button>
          <% end %>
          <.button variant="danger" phx-click="action_destroy" size="md" id="delete_btn">
            删除
          </.button>
        </.flex>
      </.section>
      <.section layout="none" id="info_section">
        <.card variant="default" id="info_card">
          <.card_header id="info_header">
            <.card_title id="info_title">
              基本信息
            </.card_title>
          </.card_header>
          <.card_content id="info_content">
            <%= if !(@editing && @editing != []) do %>
              <.grid columns={2} gap={4} id="info_grid">
                <.grid columns={2} gap={3} id="detail_fields">
                  <.stack gap={0} direction="column" id="detail_fields_supplier_code">
                    <.text variant="caption" color="muted" id="detail_fields_supplier_code_label">
                      供应商编码
                    </.text>
                    <.text id="detail_fields_supplier_code_value">
                      <%= get_in(@flight_offer, [:supplier_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_itinerary_code">
                    <.text variant="caption" color="muted" id="detail_fields_itinerary_code_label">
                      行程编码
                    </.text>
                    <.text id="detail_fields_itinerary_code_value">
                      <%= get_in(@flight_offer, [:itinerary_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_flight_no">
                    <.text variant="caption" color="muted" id="detail_fields_flight_no_label">
                      航班号
                    </.text>
                    <.text id="detail_fields_flight_no_value">
                      <%= get_in(@flight_offer, [:flight_no]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_departure_airport_code">
                    <.text variant="caption" color="muted" id="detail_fields_departure_airport_code_label">
                      出发机场编码
                    </.text>
                    <.text id="detail_fields_departure_airport_code_value">
                      <%= get_in(@flight_offer, [:departure_airport_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_arrival_airport_code">
                    <.text variant="caption" color="muted" id="detail_fields_arrival_airport_code_label">
                      到达机场编码
                    </.text>
                    <.text id="detail_fields_arrival_airport_code_value">
                      <%= get_in(@flight_offer, [:arrival_airport_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_departure_at">
                    <.text variant="caption" color="muted" id="detail_fields_departure_at_label">
                      起飞时间
                    </.text>
                    <.text id="detail_fields_departure_at_value">
                      <%= get_in(@flight_offer, [:departure_at]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_arrival_at">
                    <.text variant="caption" color="muted" id="detail_fields_arrival_at_label">
                      到达时间
                    </.text>
                    <.text id="detail_fields_arrival_at_value">
                      <%= get_in(@flight_offer, [:arrival_at]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_cabin_class">
                    <.text variant="caption" color="muted" id="detail_fields_cabin_class_label">
                      舱等
                    </.text>
                    <.text id="detail_fields_cabin_class_value">
                      <%= get_in(@flight_offer, [:cabin_class]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_fare_family">
                    <.text variant="caption" color="muted" id="detail_fields_fare_family_label">
                      运价族
                    </.text>
                    <.text id="detail_fields_fare_family_value">
                      <%= get_in(@flight_offer, [:fare_family]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_listed_price">
                    <.text variant="caption" color="muted" id="detail_fields_listed_price_label">
                      对客展示价快照
                    </.text>
                    <.text id="detail_fields_listed_price_value">
                      <%= get_in(@flight_offer, [:listed_price]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_settlement_price">
                    <.text variant="caption" color="muted" id="detail_fields_settlement_price_label">
                      结算价快照
                    </.text>
                    <.text id="detail_fields_settlement_price_value">
                      <%= get_in(@flight_offer, [:settlement_price]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_currency">
                    <.text variant="caption" color="muted" id="detail_fields_currency_label">
                      currency
                    </.text>
                    <.text id="detail_fields_currency_value">
                      <%= get_in(@flight_offer, [:currency]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_seats_available">
                    <.text variant="caption" color="muted" id="detail_fields_seats_available_label">
                      可售座位快照
                    </.text>
                    <.text id="detail_fields_seats_available_value">
                      <%= get_in(@flight_offer, [:seats_available]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_baggage_policy">
                    <.text variant="caption" color="muted" id="detail_fields_baggage_policy_label">
                      行李规则快照
                    </.text>
                    <.text id="detail_fields_baggage_policy_value">
                      <%= get_in(@flight_offer, [:baggage_policy]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_refund_change_policy">
                    <.text variant="caption" color="muted" id="detail_fields_refund_change_policy_label">
                      退改规则快照
                    </.text>
                    <.text id="detail_fields_refund_change_policy_value">
                      <%= get_in(@flight_offer, [:refund_change_policy]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_sale_status">
                    <.text variant="caption" color="muted" id="detail_fields_sale_status_label">
                      sale_status
                    </.text>
                    <.text id="detail_fields_sale_status_value">
                      <%= get_in(@flight_offer, [:sale_status]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                </.grid>
              </.grid>
            <% else %>
              <.form for={%{}} phx-submit="form_submit" phx-change="form_change" id="flight_offer_edit_form">
                <.grid columns={2} gap={4} id="form_grid">
                  <.stack direction="column" id="form_fields">
                    <.input size="md" name="flight_offer[tenant_id]" id="flight_offer_form_tenant_id" value={get_in(@flight_offer, [:tenant_id]) || ""} />
                    <.input size="md" name="flight_offer[host_shop_id]" id="flight_offer_form_host_shop_id" value={get_in(@flight_offer, [:host_shop_id]) || ""} />
                    <.input size="md" name="flight_offer[supplier_code]" id="flight_offer_form_supplier_code" value={get_in(@flight_offer, [:supplier_code]) || ""} />
                    <.input size="md" name="flight_offer[itinerary_code]" id="flight_offer_form_itinerary_code" value={get_in(@flight_offer, [:itinerary_code]) || ""} />
                    <.input size="md" name="flight_offer[flight_no]" id="flight_offer_form_flight_no" value={get_in(@flight_offer, [:flight_no]) || ""} />
                    <.input size="md" name="flight_offer[departure_airport_code]" id="flight_offer_form_departure_airport_code" value={get_in(@flight_offer, [:departure_airport_code]) || ""} />
                    <.input size="md" name="flight_offer[departure_airport_ref_id]" id="flight_offer_form_departure_airport_ref_id" value={get_in(@flight_offer, [:departure_airport_ref_id]) || ""} />
                    <.input size="md" name="flight_offer[arrival_airport_code]" id="flight_offer_form_arrival_airport_code" value={get_in(@flight_offer, [:arrival_airport_code]) || ""} />
                    <.input size="md" name="flight_offer[arrival_airport_ref_id]" id="flight_offer_form_arrival_airport_ref_id" value={get_in(@flight_offer, [:arrival_airport_ref_id]) || ""} />
                    <.input size="md" name="flight_offer[departure_at]" id="flight_offer_form_departure_at" value={get_in(@flight_offer, [:departure_at]) || ""} />
                    <.input size="md" name="flight_offer[arrival_at]" id="flight_offer_form_arrival_at" value={get_in(@flight_offer, [:arrival_at]) || ""} />
                    <.input size="md" name="flight_offer[cabin_class]" id="flight_offer_form_cabin_class" value={get_in(@flight_offer, [:cabin_class]) || ""} />
                    <.input size="md" name="flight_offer[fare_family]" id="flight_offer_form_fare_family" value={get_in(@flight_offer, [:fare_family]) || ""} />
                    <.input size="md" name="flight_offer[listed_price]" id="flight_offer_form_listed_price" value={get_in(@flight_offer, [:listed_price]) || ""} />
                    <.input size="md" name="flight_offer[settlement_price]" id="flight_offer_form_settlement_price" value={get_in(@flight_offer, [:settlement_price]) || ""} />
                    <.input size="md" name="flight_offer[currency]" id="flight_offer_form_currency" value={get_in(@flight_offer, [:currency]) || ""} />
                    <.input size="md" name="flight_offer[seats_available]" id="flight_offer_form_seats_available" value={get_in(@flight_offer, [:seats_available]) || ""} />
                    <.textarea name="flight_offer[baggage_policy]" id="flight_offer_form_baggage_policy" value={get_in(@flight_offer, [:baggage_policy]) || ""} />
                    <.textarea name="flight_offer[refund_change_policy]" id="flight_offer_form_refund_change_policy" value={get_in(@flight_offer, [:refund_change_policy]) || ""} />
                    <.select size="md" name="flight_offer[sale_status]" id="flight_offer_form_sale_status" :let={builder} value={get_in(@flight_offer, [:sale_status]) || ""}>
                      <.select_trigger builder={builder} />
                      <.select_content builder={builder}>
                        <.select_group>
                          <.select_item builder={builder} value="draft" label="draft">draft</.select_item>
                          <.select_item builder={builder} value="active" label="active">active</.select_item>
                          <.select_item builder={builder} value="inactive" label="inactive">inactive</.select_item>
                          <.select_item builder={builder} value="expired" label="expired">expired</.select_item>
                        </.select_group>
                      </.select_content>
                    </.select>
                  </.stack>
                </.grid>
                <.flex justify="end" gap={2} direction="row" id="form_actions">
                  <.button variant="secondary" phx-click="cancel_edit" size="md" id="cancel_btn">
                    取消
                  </.button>
                  <.button variant="primary" size="md" type="submit" id="save_btn">
                    保存
                  </.button>
                </.flex>
              </.form>
            <% end %>
          </.card_content>
        </.card>
      </.section>
    </.page>
    """
  end
end
