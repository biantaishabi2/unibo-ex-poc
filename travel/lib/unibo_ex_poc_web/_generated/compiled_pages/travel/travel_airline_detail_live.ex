defmodule UniboExPocWeb.Pages.Travel.TravelAirlineDetailLive do
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

  @page_id "travel_airline_detail"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): editing, travel_airline, travel_airline.airline_code, travel_airline.airline_name, travel_airline.iata_code, travel_airline.icao_code, travel_airline.status
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"travel_airline\": {
    \"airline_code\": \"\",
    \"airline_name\": \"\",
    \"iata_code\": \"\",
    \"icao_code\": \"\",
    \"status\": \"\"
  },
  \"editing\": false
}")
  # NOTE: we atomize at runtime (mount/3) and store the result in assigns.__status_defaults.

  # Backend dispatch contract (Layer-2 behavior): mode + API placeholders.
  @backend_mode "api"
  @backend_mod UniboExPocWeb.Graphql.StitchBackend
  @runtime_config_mod UniboExPocWeb.Graphql.RuntimeConfig
  @backend_fun :dispatch
  @backend_load_event "get"
  @backend_load_selection "airline_code: airlineCode airline_name: airlineName iata_code: iataCode icao_code: icaoCode id status"
  @backend_load_assigns %{travel_airline: %{}}
  @backend_params_accept ["id", "airline_name", "airline_code", "icao_code", "status", "iata_code"]
  @backend_info_reload_messages []
  @backend_api_map %{
    "create" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelAirline.create"},
    "get" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelAirline.get"},
    "update" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelAirline.update"}
  }
  @backend_embedded_page %{page_id: "travel_airline_detail", page_kind: "detail", api_map: %{create: "Travel.TravelAirline.create", get: "Travel.TravelAirline.get", update: "Travel.TravelAirline.update"}, backend: %{load: %{selection: "airline_code: airlineCode airline_name: airlineName iata_code: iataCode icao_code: icaoCode id status"}}, route: %{path: "/pages/travel/travel_airline/:id", query: "", kind: "detail"}, state_schema: %{defaults: %{travel_airline: %{airline_code: "", airline_name: "", iata_code: "", icao_code: "", status: ""}, editing: false}}, status_keys: ["record", "editing", "form", "loading"]}
  @entity_assign_fields ["airline_code", "airline_name", "iata_code", "icao_code", "status"]
  @status_key_roots [:record, :editing, :form, :loading]
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
    # Optional async contract: 仅当页面声明允许的 reload/info 消息时再转发给 backend。
    socket =
      if __accept_backend_info?(msg) and function_exported?(@backend_mod, :handle_info, 2) do
        state0 = __take_status(socket.assigns)
        apply_backend_result(socket, apply(@backend_mod, :handle_info, [msg, state0]))
      else
        socket
      end
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_destroy", params, socket) do
    # UI action event name: action_destroy
    socket = dispatch_backend("action_destroy", params, socket)
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
    # Unified backend result format (v1):
    #   {:ok, %{dto: map, status: map, effects: list, errors: list, meta: map}}
    #
    # Template compatibility note: this skeleton still assigns flat keys.
    params = params |> __merge_backend_params(socket) |> __inject_backend_id(socket) |> Map.put("__page_id", @page_id)
    result =
      case @backend_mode do
        "transitions" ->
          state0 = __take_status(socket.assigns)
          state0 = __inject_backend_tenant(state0, socket)
          %{assigns: assigns2, effects: effects} = __apply_transitions(event, params, state0)
          {dto, st} = __split_dto_status(assigns2)
          {:ok, %{dto: dto, status: st, effects: effects, errors: [], meta: %{mode: "transitions"}}}
        "api" ->
          state0 = __take_status(socket.assigns)
          state0 = __inject_backend_tenant(state0, socket)
          state0 = if is_map(@backend_embedded_page) and map_size(@backend_embedded_page) > 0, do: Map.put(state0, "__compiled_backend_page", @backend_embedded_page), else: state0
          backend_api = __resolve_backend_api(event, socket)
          case backend_api do
            nil ->
              # 纯 UI 事件不应硬塞给后端；compiled 页面这里直接走本地 transition。
              %{assigns: assigns2, effects: effects} = __apply_transitions(event, params, state0)
              {dto, st} = __split_dto_status(assigns2)
              {:ok, %{dto: dto, status: st, effects: effects, errors: [], meta: %{mode: "api_local_transition"}}}
            _mapping ->
              apply(@backend_mod, @backend_fun, [event, params, state0])
          end
      end

    apply_backend_result(socket, result)
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
          get_in(socket.assigns, [:travel_airline, :id]) ||
          get_in(socket.assigns, [:travel_airline, "id"])
      case id do
        value when is_binary(value) and value != "" -> Map.put(params, "id", value)
        _ -> params
      end
    end
  end
  defp __inject_backend_id(params, _socket), do: params

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
      %{travel_airline: entity} when is_map(entity) and map_size(entity) > 0 -> assign(socket, :travel_airline, entity)
      %{record: entity} when is_map(entity) ->
        case __assign_map_present?(entity) do
          true -> assign(socket, :travel_airline, entity)
          false -> socket
        end
      _ ->
        source =
          Enum.reduce(@entity_assign_fields, %{}, fn key, acc ->
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
          entity = Map.get(socket.assigns, :travel_airline, %{})
          entity = if is_map(entity), do: Map.merge(entity, source), else: source
          assign(socket, :travel_airline, entity)
        end
    end
  end
  defp __sync_entity_assign(socket, _dto), do: socket

  defp __sync_record_alias(socket) do
    case socket.assigns do
      %{travel_airline: entity} when is_map(entity) ->
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

  defp __apply_transitions("cancel_edit", params, assigns) do
  assigns = assigns
  effects = []
  assigns = __put_in_path(assigns, [:editing], false)
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions("form_change", params, assigns) do
  assigns = assigns
  effects = []
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions("form_submit", params, assigns) do
  assigns = assigns
  effects = []
  assigns = __put_in_path(assigns, [:editing], false)
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions("toggle_edit", params, assigns) do
  assigns = assigns
  effects = []
  assigns = __update_in_path(assigns, [:editing], fn cur ->
    cur = if is_boolean(cur), do: cur, else: false
    !cur
  end)
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions(_event, _params, assigns), do: %{assigns: assigns, effects: []}

  def render(assigns) do
    ~H"""
    <.page title="详情" id="travel_airline_detail">
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
              TravelAirline
            </.text>
            <.text variant="h1" id="page_title">
              航司主数据（Travel 层,来源 OFBiz PartyGroup）
            </.text>
          </.stack>
          <%= case get_in(@travel_airline, [:status]) do %>
            <% "active" -> %>
              <.badge color="green">active</.badge>
            <% "inactive" -> %>
              <.badge color="red">inactive</.badge>
            <% _ -> %>
              <.badge />
          <% end %>
        </.flex>
        <.flex gap={2} direction="row" id="actions_group">
          <.button variant="secondary" phx-click="toggle_edit" size="md" id="edit_btn">
            编辑
          </.button>
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
                  <.stack gap={0} direction="column" id="detail_fields_airline_code">
                    <.text variant="caption" color="muted" id="detail_fields_airline_code_label">
                      航司规范编码
                    </.text>
                    <.text id="detail_fields_airline_code_value">
                      <%= get_in(@travel_airline, [:airline_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_airline_name">
                    <.text variant="caption" color="muted" id="detail_fields_airline_name_label">
                      航司名称
                    </.text>
                    <.text id="detail_fields_airline_name_value">
                      <%= get_in(@travel_airline, [:airline_name]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_iata_code">
                    <.text variant="caption" color="muted" id="detail_fields_iata_code_label">
                      IATA 二字码
                    </.text>
                    <.text id="detail_fields_iata_code_value">
                      <%= get_in(@travel_airline, [:iata_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_icao_code">
                    <.text variant="caption" color="muted" id="detail_fields_icao_code_label">
                      ICAO 三字码
                    </.text>
                    <.text id="detail_fields_icao_code_value">
                      <%= get_in(@travel_airline, [:icao_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_status">
                    <.text variant="caption" color="muted" id="detail_fields_status_label">
                      status
                    </.text>
                    <.text id="detail_fields_status_value">
                      <%= get_in(@travel_airline, [:status]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                </.grid>
              </.grid>
            <% else %>
              <.form for={%{}} phx-submit="form_submit" phx-change="form_change" id="travel_airline_edit_form">
                <.grid columns={2} gap={4} id="form_grid">
                  <.stack direction="column" id="form_fields">
                    <.input size="md" name="travel_airline[airline_code]" id="travel_airline_form_airline_code" value={get_in(@travel_airline, [:airline_code]) || ""} />
                    <.input size="md" name="travel_airline[airline_name]" id="travel_airline_form_airline_name" value={get_in(@travel_airline, [:airline_name]) || ""} />
                    <.input size="md" name="travel_airline[iata_code]" id="travel_airline_form_iata_code" value={get_in(@travel_airline, [:iata_code]) || ""} />
                    <.input size="md" name="travel_airline[icao_code]" id="travel_airline_form_icao_code" value={get_in(@travel_airline, [:icao_code]) || ""} />
                    <.select size="md" name="travel_airline[status]" id="travel_airline_form_status" :let={builder} value={get_in(@travel_airline, [:status]) || ""}>
                      <.select_trigger builder={builder} />
                      <.select_content builder={builder}>
                        <.select_group>
                          <.select_item builder={builder} value="active" label="active">active</.select_item>
                          <.select_item builder={builder} value="inactive" label="inactive">inactive</.select_item>
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
