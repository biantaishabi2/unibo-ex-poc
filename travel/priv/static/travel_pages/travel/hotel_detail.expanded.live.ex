defmodule UniboExPocWeb.Pages.Travel.HotelDetailLive do
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

  @page_id "hotel_detail"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): editing, hotel_offer, hotel_offer.cancellation_policy, hotel_offer.checkin_date, hotel_offer.checkout_date, hotel_offer.city_code, hotel_offer.currency, hotel_offer.guarantee_policy, hotel_offer.hotel_code, hotel_offer.hotel_name, hotel_offer.inventory_count, hotel_offer.listed_price, hotel_offer.rate_plan_code, hotel_offer.room_type_code, hotel_offer.sale_status, hotel_offer.settlement_price, hotel_offer.supplier_code, record, record.sale_status
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"record\": {
    \"sale_status\": true
  },
  \"hotel_offer\": {
    \"supplier_code\": \"\",
    \"hotel_code\": \"\",
    \"hotel_name\": \"\",
    \"city_code\": \"\",
    \"room_type_code\": \"\",
    \"rate_plan_code\": \"\",
    \"checkin_date\": \"\",
    \"checkout_date\": \"\",
    \"listed_price\": \"\",
    \"settlement_price\": \"\",
    \"currency\": \"\",
    \"inventory_count\": \"\",
    \"cancellation_policy\": \"\",
    \"guarantee_policy\": \"\",
    \"sale_status\": \"\"
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
  @backend_load_selection "id"
  @backend_load_assigns %{hotel_offer: %{}}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{
    "get" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.HotelOffer.get"},
    "list" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.HotelOffer.list"}
  }
  @backend_embedded_page %{page_id: "hotel_detail", page_kind: "detail", api_map: %{get: "Travel.HotelOffer.get", list: "Travel.HotelOffer.list"}, backend: %{load: %{selection: "id"}}, route: %{path: "/pages/travel/hotel_detail", query: "", kind: "detail"}, state_schema: %{defaults: %{record: %{sale_status: true}, hotel_offer: %{supplier_code: "", hotel_code: "", hotel_name: "", city_code: "", room_type_code: "", rate_plan_code: "", checkin_date: "", checkout_date: "", listed_price: "", settlement_price: "", currency: "", inventory_count: "", cancellation_policy: "", guarantee_policy: "", sale_status: ""}, editing: false}}, status_keys: []}
  @entity_assign_fields ["supplier_code", "hotel_code", "hotel_name", "city_code", "room_type_code", "rate_plan_code", "checkin_date", "checkout_date", "listed_price", "settlement_price", "currency", "inventory_count", "cancellation_policy", "guarantee_policy", "sale_status"]
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
          # 先获取本地 transition 定义的 effects（如 destroy 后的 navigate）
          %{effects: local_effects} = __apply_transitions(event, params, state0)
          backend_api = __resolve_backend_api(event, socket)
          case backend_api do
            nil ->
              # 纯 UI 事件，直接走本地 transition
              %{assigns: assigns2, effects: effects} = __apply_transitions(event, params, state0)
              {dto, st} = __split_dto_status(assigns2)
              {:ok, %{dto: dto, status: st, effects: effects, errors: [], meta: %{mode: "api_local_transition"}}}
            _mapping ->
              backend_result = apply(@backend_mod, @backend_fun, [event, params, state0])
              # 合并本地 transition effects（如 destroy 后 navigate）到后端返回结果
              case {backend_result, local_effects} do
                {{:ok, %{} = data}, [_ | _]} ->
                  existing = Map.get(data, :effects, [])
                  {:ok, Map.put(data, :effects, existing ++ local_effects)}
                _ ->
                  backend_result
              end
          end
      end

    # destroy 成功后自动跳转到 list 页（从 self_path 推导，去掉最后一段 /:id）
    result = __maybe_inject_destroy_redirect(event, result, socket)
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
          get_in(socket.assigns, [:hotel_offer, :id]) ||
          get_in(socket.assigns, [:hotel_offer, "id"])
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
      %{hotel_offer: entity} when is_map(entity) and map_size(entity) > 0 -> assign(socket, :hotel_offer, entity)
      %{record: entity} when is_map(entity) ->
        case __assign_map_present?(entity) do
          true -> assign(socket, :hotel_offer, entity)
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
          entity = Map.get(socket.assigns, :hotel_offer, %{})
          entity = if is_map(entity), do: Map.merge(entity, source), else: source
          assign(socket, :hotel_offer, entity)
        end
    end
  end
  defp __sync_entity_assign(socket, _dto), do: socket

  defp __sync_record_alias(socket) do
    case socket.assigns do
      %{hotel_offer: entity} when is_map(entity) ->
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
    <.page title="详情" id="hotel_detail">
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
              HotelOffer
            </.text>
            <.text variant="h1" id="page_title">
              酒店可售 offer,承载房型、价计划、价态和可售规则快照
            </.text>
          </.stack>
          <.badge bind="hotel_offer.status" variant="default" size="sm" id="status_badge" />
        </.flex>
        <.flex gap={2} direction="row" id="actions_group">
          <.button variant="secondary" phx-click="toggle_edit" size="md" id="edit_btn">
            编辑
          </.button>
          <%= if to_string(get_in(@record, [:sale_status])) == "draft" || to_string(get_in(@record, [:sale_status])) == "inactive" do %>
            <.button variant="secondary" phx-click="action_activate" size="md" id="hotel_offer_action_activate">
              activate
            </.button>
          <% end %>
          <%= if to_string(get_in(@record, [:sale_status])) == "active" do %>
            <.button variant="secondary" phx-click="action_deactivate" size="md" id="hotel_offer_action_deactivate">
              deactivate
            </.button>
          <% end %>
          <%= if to_string(get_in(@record, [:sale_status])) == "active" do %>
            <.button variant="secondary" phx-click="action_expire" size="md" id="hotel_offer_action_expire">
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
                      <%= get_in(@hotel_offer, [:supplier_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_hotel_code">
                    <.text variant="caption" color="muted" id="detail_fields_hotel_code_label">
                      酒店编码
                    </.text>
                    <.text id="detail_fields_hotel_code_value">
                      <%= get_in(@hotel_offer, [:hotel_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_hotel_name">
                    <.text variant="caption" color="muted" id="detail_fields_hotel_name_label">
                      酒店名称
                    </.text>
                    <.text id="detail_fields_hotel_name_value">
                      <%= get_in(@hotel_offer, [:hotel_name]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_city_code">
                    <.text variant="caption" color="muted" id="detail_fields_city_code_label">
                      城市编码
                    </.text>
                    <.text id="detail_fields_city_code_value">
                      <%= get_in(@hotel_offer, [:city_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_room_type_code">
                    <.text variant="caption" color="muted" id="detail_fields_room_type_code_label">
                      房型编码
                    </.text>
                    <.text id="detail_fields_room_type_code_value">
                      <%= get_in(@hotel_offer, [:room_type_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_rate_plan_code">
                    <.text variant="caption" color="muted" id="detail_fields_rate_plan_code_label">
                      价计划编码
                    </.text>
                    <.text id="detail_fields_rate_plan_code_value">
                      <%= get_in(@hotel_offer, [:rate_plan_code]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_checkin_date">
                    <.text variant="caption" color="muted" id="detail_fields_checkin_date_label">
                      入住日期
                    </.text>
                    <.text id="detail_fields_checkin_date_value">
                      <%= get_in(@hotel_offer, [:checkin_date]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_checkout_date">
                    <.text variant="caption" color="muted" id="detail_fields_checkout_date_label">
                      离店日期
                    </.text>
                    <.text id="detail_fields_checkout_date_value">
                      <%= get_in(@hotel_offer, [:checkout_date]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_listed_price">
                    <.text variant="caption" color="muted" id="detail_fields_listed_price_label">
                      对客展示价快照
                    </.text>
                    <.text id="detail_fields_listed_price_value">
                      <%= get_in(@hotel_offer, [:listed_price]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_settlement_price">
                    <.text variant="caption" color="muted" id="detail_fields_settlement_price_label">
                      结算价快照
                    </.text>
                    <.text id="detail_fields_settlement_price_value">
                      <%= get_in(@hotel_offer, [:settlement_price]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_currency">
                    <.text variant="caption" color="muted" id="detail_fields_currency_label">
                      币种
                    </.text>
                    <.text id="detail_fields_currency_value">
                      <%= get_in(@hotel_offer, [:currency]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_inventory_count">
                    <.text variant="caption" color="muted" id="detail_fields_inventory_count_label">
                      可售库存快照
                    </.text>
                    <.text id="detail_fields_inventory_count_value">
                      <%= get_in(@hotel_offer, [:inventory_count]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_cancellation_policy">
                    <.text variant="caption" color="muted" id="detail_fields_cancellation_policy_label">
                      取消规则快照
                    </.text>
                    <.text id="detail_fields_cancellation_policy_value">
                      <%= get_in(@hotel_offer, [:cancellation_policy]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_guarantee_policy">
                    <.text variant="caption" color="muted" id="detail_fields_guarantee_policy_label">
                      担保规则快照
                    </.text>
                    <.text id="detail_fields_guarantee_policy_value">
                      <%= get_in(@hotel_offer, [:guarantee_policy]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_sale_status">
                    <.text variant="caption" color="muted" id="detail_fields_sale_status_label">
                      可售状态
                    </.text>
                    <.text id="detail_fields_sale_status_value">
                      <%= get_in(@hotel_offer, [:sale_status]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                </.grid>
              </.grid>
            <% else %>
              <.form for={%{}} phx-submit="form_submit" phx-change="form_change" id="hotel_offer_edit_form">
                <.grid columns={2} gap={4} id="form_grid">
                  <.stack direction="column" id="form_fields">
                    <.input size="md" name="hotel_offer[tenant_id]" id="hotel_offer_form_tenant_id" value={get_in(@hotel_offer, [:tenant_id]) || ""} />
                    <.input size="md" name="hotel_offer[host_shop_id]" id="hotel_offer_form_host_shop_id" value={get_in(@hotel_offer, [:host_shop_id]) || ""} />
                    <.input size="md" name="hotel_offer[supplier_code]" id="hotel_offer_form_supplier_code" value={get_in(@hotel_offer, [:supplier_code]) || ""} />
                    <.input size="md" name="hotel_offer[hotel_code]" id="hotel_offer_form_hotel_code" value={get_in(@hotel_offer, [:hotel_code]) || ""} />
                    <.input size="md" name="hotel_offer[hotel_name]" id="hotel_offer_form_hotel_name" value={get_in(@hotel_offer, [:hotel_name]) || ""} />
                    <.input size="md" name="hotel_offer[city_code]" id="hotel_offer_form_city_code" value={get_in(@hotel_offer, [:city_code]) || ""} />
                    <.input size="md" name="hotel_offer[city_ref_id]" id="hotel_offer_form_city_ref_id" value={get_in(@hotel_offer, [:city_ref_id]) || ""} />
                    <.input size="md" name="hotel_offer[room_type_code]" id="hotel_offer_form_room_type_code" value={get_in(@hotel_offer, [:room_type_code]) || ""} />
                    <.input size="md" name="hotel_offer[rate_plan_code]" id="hotel_offer_form_rate_plan_code" value={get_in(@hotel_offer, [:rate_plan_code]) || ""} />
                    <.input size="md" name="hotel_offer[checkin_date]" id="hotel_offer_form_checkin_date" value={get_in(@hotel_offer, [:checkin_date]) || ""} />
                    <.input size="md" name="hotel_offer[checkout_date]" id="hotel_offer_form_checkout_date" value={get_in(@hotel_offer, [:checkout_date]) || ""} />
                    <.input size="md" name="hotel_offer[listed_price]" id="hotel_offer_form_listed_price" value={get_in(@hotel_offer, [:listed_price]) || ""} />
                    <.input size="md" name="hotel_offer[settlement_price]" id="hotel_offer_form_settlement_price" value={get_in(@hotel_offer, [:settlement_price]) || ""} />
                    <.input size="md" name="hotel_offer[currency]" id="hotel_offer_form_currency" value={get_in(@hotel_offer, [:currency]) || ""} />
                    <.input size="md" name="hotel_offer[inventory_count]" id="hotel_offer_form_inventory_count" value={get_in(@hotel_offer, [:inventory_count]) || ""} />
                    <.textarea name="hotel_offer[cancellation_policy]" id="hotel_offer_form_cancellation_policy" value={get_in(@hotel_offer, [:cancellation_policy]) || ""} />
                    <.textarea name="hotel_offer[guarantee_policy]" id="hotel_offer_form_guarantee_policy" value={get_in(@hotel_offer, [:guarantee_policy]) || ""} />
                    <.select size="md" name="hotel_offer[sale_status]" id="hotel_offer_form_sale_status" :let={builder} value={get_in(@hotel_offer, [:sale_status]) || ""}>
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
