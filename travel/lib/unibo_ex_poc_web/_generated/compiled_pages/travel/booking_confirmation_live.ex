defmodule UniboExPocWeb.Pages.Travel.BookingConfirmationLive do
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

  @page_id "booking_confirmation"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): editing, record, record.status, travel_order, travel_order.booking_mode, travel_order.change_status, travel_order.contact_name, travel_order.contact_phone, travel_order.currency, travel_order.order_no, travel_order.original_order_ref, travel_order.payment_external_ref, travel_order.points_deduction_amount, travel_order.points_to_use, travel_order.product_type, travel_order.recommended_payment_method, travel_order.seat_selection_snapshot, travel_order.status, travel_order.supplier_order_ref, travel_order.ticket_passenger_infos, travel_order.total_amount, travel_order.traveler_count, travel_order.waitlist_status
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"record\": {
    \"status\": true
  },
  \"travel_order\": {
    \"order_no\": \"\",
    \"product_type\": \"\",
    \"booking_mode\": \"\",
    \"contact_name\": \"\",
    \"contact_phone\": \"\",
    \"traveler_count\": \"\",
    \"total_amount\": \"\",
    \"points_to_use\": \"\",
    \"points_deduction_amount\": \"\",
    \"recommended_payment_method\": \"\",
    \"currency\": \"\",
    \"status\": \"\",
    \"change_status\": \"\",
    \"waitlist_status\": \"\",
    \"original_order_ref\": \"\",
    \"ticket_passenger_infos\": \"\",
    \"seat_selection_snapshot\": \"\",
    \"supplier_order_ref\": \"\",
    \"payment_external_ref\": \"\"
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
  @backend_load_assigns %{travel_order: %{}}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{
    "get" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelOrder.get"},
    "list" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelOrder.list"}
  }
  @backend_embedded_page %{page_id: "booking_confirmation", page_kind: "detail", api_map: %{get: "Travel.TravelOrder.get", list: "Travel.TravelOrder.list"}, backend: %{load: %{selection: "id"}}, route: %{path: "/pages/travel/booking_confirmation", query: "", kind: "detail"}, state_schema: %{defaults: %{record: %{status: true}, travel_order: %{order_no: "", product_type: "", booking_mode: "", contact_name: "", contact_phone: "", traveler_count: "", total_amount: "", points_to_use: "", points_deduction_amount: "", recommended_payment_method: "", currency: "", status: "", change_status: "", waitlist_status: "", original_order_ref: "", ticket_passenger_infos: "", seat_selection_snapshot: "", supplier_order_ref: "", payment_external_ref: ""}, editing: false}}, status_keys: []}
  @entity_assign_fields ["order_no", "product_type", "booking_mode", "contact_name", "contact_phone", "traveler_count", "total_amount", "points_to_use", "points_deduction_amount", "recommended_payment_method", "currency", "status", "change_status", "waitlist_status", "original_order_ref", "ticket_passenger_infos", "seat_selection_snapshot", "supplier_order_ref", "payment_external_ref"]
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
  def handle_event("action_cancel_cancel_request", params, socket) do
    # UI action event name: action_cancel_cancel_request
    socket = dispatch_backend("action_cancel_cancel_request", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_cancel_waitlist", params, socket) do
    # UI action event name: action_cancel_waitlist
    socket = dispatch_backend("action_cancel_waitlist", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_confirm_change", params, socket) do
    # UI action event name: action_confirm_change
    socket = dispatch_backend("action_confirm_change", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_confirm_quote", params, socket) do
    # UI action event name: action_confirm_quote
    socket = dispatch_backend("action_confirm_quote", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_destroy", params, socket) do
    # UI action event name: action_destroy
    socket = dispatch_backend("action_destroy", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_execute_cancel", params, socket) do
    # UI action event name: action_execute_cancel
    socket = dispatch_backend("action_execute_cancel", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_fulfill_waitlist", params, socket) do
    # UI action event name: action_fulfill_waitlist
    socket = dispatch_backend("action_fulfill_waitlist", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_mark_booked", params, socket) do
    # UI action event name: action_mark_booked
    socket = dispatch_backend("action_mark_booked", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_mark_completed", params, socket) do
    # UI action event name: action_mark_completed
    socket = dispatch_backend("action_mark_completed", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_mark_order_failed", params, socket) do
    # UI action event name: action_mark_order_failed
    socket = dispatch_backend("action_mark_order_failed", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_mark_payment_succeeded", params, socket) do
    # UI action event name: action_mark_payment_succeeded
    socket = dispatch_backend("action_mark_payment_succeeded", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_request_cancel", params, socket) do
    # UI action event name: action_request_cancel
    socket = dispatch_backend("action_request_cancel", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_request_change", params, socket) do
    # UI action event name: action_request_change
    socket = dispatch_backend("action_request_change", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_submit_order", params, socket) do
    # UI action event name: action_submit_order
    socket = dispatch_backend("action_submit_order", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("action_submit_waitlist", params, socket) do
    # UI action event name: action_submit_waitlist
    socket = dispatch_backend("action_submit_waitlist", params, socket)
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
          get_in(socket.assigns, [:travel_order, :id]) ||
          get_in(socket.assigns, [:travel_order, "id"])
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
      %{travel_order: entity} when is_map(entity) and map_size(entity) > 0 -> assign(socket, :travel_order, entity)
      %{record: entity} when is_map(entity) ->
        case __assign_map_present?(entity) do
          true -> assign(socket, :travel_order, entity)
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
          entity = Map.get(socket.assigns, :travel_order, %{})
          entity = if is_map(entity), do: Map.merge(entity, source), else: source
          assign(socket, :travel_order, entity)
        end
    end
  end
  defp __sync_entity_assign(socket, _dto), do: socket

  defp __sync_record_alias(socket) do
    case socket.assigns do
      %{travel_order: entity} when is_map(entity) ->
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
    <.page title="详情" id="booking_confirmation">
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
              TravelOrder
            </.text>
            <.text variant="h1" id="page_title">
              统一酒旅订单,承接 hotel、flight、vacation、train 四类商品的下单和状态流转;通过跨域引用关联 Sales::Customer 和 Payment::Payment
            </.text>
          </.stack>
          <%= case get_in(@travel_order, [:status]) do %>
            <% "draft" -> %>
              <.badge color="yellow">draft</.badge>
            <% "quoted" -> %>
              <.badge color="blue">quoted</.badge>
            <% "submitted" -> %>
              <.badge color="blue">submitted</.badge>
            <% "booking_pending" -> %>
              <.badge color="blue">booking_pending</.badge>
            <% "booked" -> %>
              <.badge color="blue">booked</.badge>
            <% "cancel_pending" -> %>
              <.badge color="blue">cancel_pending</.badge>
            <% "cancelled" -> %>
              <.badge color="red">cancelled</.badge>
            <% "completed" -> %>
              <.badge color="green">completed</.badge>
            <% "failed" -> %>
              <.badge color="blue">failed</.badge>
            <% _ -> %>
              <.badge />
          <% end %>
        </.flex>
        <.flex gap={2} direction="row" id="actions_group">
          <.button variant="secondary" phx-click="toggle_edit" size="md" id="edit_btn">
            编辑
          </.button>
          <%= if get_in(@record, [:status]) == "draft" do %>
            <.button variant="secondary" phx-click="action_confirm_quote" size="md" id="travel_order_action_confirm_quote">
              confirm_quote
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "quoted" do %>
            <.button variant="secondary" phx-click="action_submit_order" size="md" id="travel_order_action_submit_order">
              submit_order
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "quoted" do %>
            <.button variant="secondary" phx-click="action_submit_waitlist" size="md" id="travel_order_action_submit_waitlist">
              submit_waitlist
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "submitted" do %>
            <.button variant="secondary" phx-click="action_mark_payment_succeeded" size="md" id="travel_order_action_mark_payment_succeeded">
              mark_payment_succeeded
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "booking_pending" do %>
            <.button variant="secondary" phx-click="action_mark_booked" size="md" id="travel_order_action_mark_booked">
              mark_booked
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "booking_pending" do %>
            <.button variant="secondary" phx-click="action_fulfill_waitlist" size="md" id="travel_order_action_fulfill_waitlist">
              fulfill_waitlist
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "booked" do %>
            <.button variant="secondary" phx-click="action_mark_completed" size="md" id="travel_order_action_mark_completed">
              mark_completed
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "booked" do %>
            <.button variant="secondary" phx-click="action_request_cancel" size="md" id="travel_order_action_request_cancel">
              request_cancel
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "booking_pending" do %>
            <.button variant="secondary" phx-click="action_cancel_waitlist" size="md" id="travel_order_action_cancel_waitlist">
              cancel_waitlist
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "cancel_pending" do %>
            <.button variant="secondary" phx-click="action_execute_cancel" size="md" id="travel_order_action_execute_cancel">
              execute_cancel
            </.button>
          <% end %>
          <%= if get_in(@record, [:status]) == "cancel_pending" do %>
            <.button variant="secondary" phx-click="action_cancel_cancel_request" size="md" id="travel_order_action_cancel_cancel_request">
              cancel_cancel_request
            </.button>
          <% end %>
          <.button variant="secondary" phx-click="action_request_change" size="md" id="travel_order_action_request_change">
            request_change
          </.button>
          <.button variant="secondary" phx-click="action_confirm_change" size="md" id="travel_order_action_confirm_change">
            confirm_change
          </.button>
          <%= if get_in(@record, [:status]) == "submitted" do %>
            <.button variant="secondary" phx-click="action_mark_order_failed" size="md" id="travel_order_action_mark_order_failed">
              mark_order_failed
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
                  <.stack gap={0} direction="column" id="detail_fields_order_no">
                    <.text variant="caption" color="muted" id="detail_fields_order_no_label">
                      订单号
                    </.text>
                    <.text id="detail_fields_order_no_value">
                      <%= get_in(@travel_order, [:order_no]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_product_type">
                    <.text variant="caption" color="muted" id="detail_fields_product_type_label">
                      商品类型
                    </.text>
                    <.text id="detail_fields_product_type_value">
                      <%= get_in(@travel_order, [:product_type]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_booking_mode">
                    <.text variant="caption" color="muted" id="detail_fields_booking_mode_label">
                      train 订单预订模式
                    </.text>
                    <.text id="detail_fields_booking_mode_value">
                      <%= get_in(@travel_order, [:booking_mode]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_contact_name">
                    <.text variant="caption" color="muted" id="detail_fields_contact_name_label">
                      contact_name
                    </.text>
                    <.text id="detail_fields_contact_name_value">
                      <%= get_in(@travel_order, [:contact_name]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_contact_phone">
                    <.text variant="caption" color="muted" id="detail_fields_contact_phone_label">
                      contact_phone
                    </.text>
                    <.text id="detail_fields_contact_phone_value">
                      <%= get_in(@travel_order, [:contact_phone]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_traveler_count">
                    <.text variant="caption" color="muted" id="detail_fields_traveler_count_label">
                      出行人数量
                    </.text>
                    <.text id="detail_fields_traveler_count_value">
                      <%= get_in(@travel_order, [:traveler_count]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_total_amount">
                    <.text variant="caption" color="muted" id="detail_fields_total_amount_label">
                      订单总金额
                    </.text>
                    <.text id="detail_fields_total_amount_value">
                      <%= get_in(@travel_order, [:total_amount]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_points_to_use">
                    <.text variant="caption" color="muted" id="detail_fields_points_to_use_label">
                      计划使用的积分数量
                    </.text>
                    <.text id="detail_fields_points_to_use_value">
                      <%= get_in(@travel_order, [:points_to_use]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_points_deduction_amount">
                    <.text variant="caption" color="muted" id="detail_fields_points_deduction_amount_label">
                      积分抵现金额
                    </.text>
                    <.text id="detail_fields_points_deduction_amount_value">
                      <%= get_in(@travel_order, [:points_deduction_amount]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_recommended_payment_method">
                    <.text variant="caption" color="muted" id="detail_fields_recommended_payment_method_label">
                      宿主 quote 返回的推荐支付方式
                    </.text>
                    <.text id="detail_fields_recommended_payment_method_value">
                      <%= get_in(@travel_order, [:recommended_payment_method]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_currency">
                    <.text variant="caption" color="muted" id="detail_fields_currency_label">
                      currency
                    </.text>
                    <.text id="detail_fields_currency_value">
                      <%= get_in(@travel_order, [:currency]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_status">
                    <.text variant="caption" color="muted" id="detail_fields_status_label">
                      status
                    </.text>
                    <.text id="detail_fields_status_value">
                      <%= get_in(@travel_order, [:status]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_change_status">
                    <.text variant="caption" color="muted" id="detail_fields_change_status_label">
                      change_status
                    </.text>
                    <.text id="detail_fields_change_status_value">
                      <%= get_in(@travel_order, [:change_status]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_waitlist_status">
                    <.text variant="caption" color="muted" id="detail_fields_waitlist_status_label">
                      waitlist_status
                    </.text>
                    <.text id="detail_fields_waitlist_status_value">
                      <%= get_in(@travel_order, [:waitlist_status]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_original_order_ref">
                    <.text variant="caption" color="muted" id="detail_fields_original_order_ref_label">
                      改签链路引用的原订单号或原票号
                    </.text>
                    <.text id="detail_fields_original_order_ref_value">
                      <%= get_in(@travel_order, [:original_order_ref]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_ticket_passenger_infos">
                    <.text variant="caption" color="muted" id="detail_fields_ticket_passenger_infos_label">
                      乘车人信息快照
                    </.text>
                    <.text id="detail_fields_ticket_passenger_infos_value">
                      <%= get_in(@travel_order, [:ticket_passenger_infos]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_seat_selection_snapshot">
                    <.text variant="caption" color="muted" id="detail_fields_seat_selection_snapshot_label">
                      选座与席别偏好快照
                    </.text>
                    <.text id="detail_fields_seat_selection_snapshot_value">
                      <%= get_in(@travel_order, [:seat_selection_snapshot]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_supplier_order_ref">
                    <.text variant="caption" color="muted" id="detail_fields_supplier_order_ref_label">
                      供应商订单号
                    </.text>
                    <.text id="detail_fields_supplier_order_ref_value">
                      <%= get_in(@travel_order, [:supplier_order_ref]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_payment_external_ref">
                    <.text variant="caption" color="muted" id="detail_fields_payment_external_ref_label">
                      宿主支付侧外部支付流水号
                    </.text>
                    <.text id="detail_fields_payment_external_ref_value">
                      <%= get_in(@travel_order, [:payment_external_ref]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                </.grid>
              </.grid>
            <% else %>
              <.form for={%{}} phx-submit="form_submit" phx-change="form_change" id="edit_form">
                <.grid columns={2} gap={4} id="form_grid">
                  <.stack direction="column" id="form_fields">
                    <.input size="md" name="travel_order[tenant_id]" id="form_tenant_id" value={get_in(@travel_order, [:tenant_id]) || ""} />
                    <.input size="md" name="travel_order[host_shop_id]" id="form_host_shop_id" value={get_in(@travel_order, [:host_shop_id]) || ""} />
                    <.input size="md" name="travel_order[order_no]" id="form_order_no" value={get_in(@travel_order, [:order_no]) || ""} />
                    <.select size="md" name="travel_order[product_type]" id="form_product_type" :let={builder} value={get_in(@travel_order, [:product_type]) || ""}>
                      <.select_trigger builder={builder} />
                      <.select_content builder={builder}>
                        <.select_group>
                          <.select_item builder={builder} value="hotel" label="hotel">hotel</.select_item>
                          <.select_item builder={builder} value="flight" label="flight">flight</.select_item>
                          <.select_item builder={builder} value="vacation" label="vacation">vacation</.select_item>
                          <.select_item builder={builder} value="train" label="train">train</.select_item>
                        </.select_group>
                      </.select_content>
                    </.select>
                    <.input size="md" name="travel_order[customer_id]" id="form_customer_id" value={get_in(@travel_order, [:customer_id]) || ""} />
                    <.input size="md" name="travel_order[contact_name]" id="form_contact_name" value={get_in(@travel_order, [:contact_name]) || ""} />
                    <.input size="md" name="travel_order[contact_phone]" id="form_contact_phone" value={get_in(@travel_order, [:contact_phone]) || ""} />
                    <.input size="md" name="travel_order[traveler_count]" id="form_traveler_count" value={get_in(@travel_order, [:traveler_count]) || ""} />
                    <.input size="md" name="travel_order[total_amount]" id="form_total_amount" value={get_in(@travel_order, [:total_amount]) || ""} />
                    <.input size="md" name="travel_order[points_to_use]" id="form_points_to_use" value={get_in(@travel_order, [:points_to_use]) || ""} />
                    <.input size="md" name="travel_order[points_deduction_amount]" id="form_points_deduction_amount" value={get_in(@travel_order, [:points_deduction_amount]) || ""} />
                    <.input size="md" name="travel_order[currency]" id="form_currency" value={get_in(@travel_order, [:currency]) || ""} />
                    <.input size="md" name="travel_order[ticket_passenger_infos]" id="form_ticket_passenger_infos" value={get_in(@travel_order, [:ticket_passenger_infos]) || ""} />
                    <.input size="md" name="travel_order[seat_selection_snapshot]" id="form_seat_selection_snapshot" value={get_in(@travel_order, [:seat_selection_snapshot]) || ""} />
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
