defmodule UniboExPocWeb.Pages.Travel.TrainBookingLive do
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

  @page_id "train_booking"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): offer, offer.arrival_station_name, offer.arrival_time, offer.currency, offer.date_label, offer.departure_station_name, offer.departure_time, offer.is_policy_exceeded, offer.selected_seat_class_name, offer.selected_seat_price, offer.total_price, offer.train_no, offer.train_type_label, travelers, travelers.items, travelers.items[], travelers.items[].avatar, travelers.items[].id_type_label, travelers.items[].name, travelers.items[].name_initial
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"offer\": {
    \"train_no\": \"\",
    \"train_type_label\": \"\",
    \"selected_seat_class_name\": \"\",
    \"departure_time\": \"\",
    \"departure_station_name\": \"\",
    \"date_label\": \"\",
    \"arrival_time\": \"\",
    \"arrival_station_name\": \"\",
    \"currency\": \"\",
    \"selected_seat_price\": \"\",
    \"is_policy_exceeded\": true,
    \"total_price\": \"\"
  },
  \"travelers\": {
    \"items\": [
      {
        \"avatar\": \"\",
        \"name_initial\": \"\",
        \"name\": \"traveler_1\",
        \"id_type_label\": \"\"
      },
      {
        \"avatar\": \"\",
        \"name_initial\": \"\",
        \"name\": \"traveler_2\",
        \"id_type_label\": \"\"
      },
      {
        \"avatar\": \"\",
        \"name_initial\": \"\",
        \"name\": \"traveler_3\",
        \"id_type_label\": \"\"
      }
    ]
  }
}")
  # NOTE: we atomize at runtime (mount/3) and store the result in assigns.__status_defaults.

  # Backend dispatch contract (Layer-2 behavior): mode + API placeholders.
  @backend_mode "api"
  @backend_mod UniboExPocWeb.Graphql.StitchBackend
  @runtime_config_mod UniboExPocWeb.Graphql.RuntimeConfig
  @backend_fun :dispatch
  @backend_load_event nil
  @backend_load_selection "id"
  @backend_load_assigns %{}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{}
  @backend_embedded_page %{page_id: "train_booking", page_kind: "custom", api_map: %{}, backend: %{load: %{selection: "id"}}, route: %{path: "/pages/travel/train_booking", query: "", kind: "custom"}, state_schema: %{defaults: %{offer: %{train_no: "", train_type_label: "", selected_seat_class_name: "", departure_time: "", departure_station_name: "", date_label: "", arrival_time: "", arrival_station_name: "", currency: "", selected_seat_price: "", is_policy_exceeded: true, total_price: ""}, travelers: %{items: [%{avatar: "", name_initial: "", name: "traveler_1", id_type_label: ""}, %{avatar: "", name_initial: "", name: "traveler_2", id_type_label: ""}, %{avatar: "", name_initial: "", name: "traveler_3", id_type_label: ""}]}}}, status_keys: []}
  @entity_assign_fields []
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
  def handle_event("add_traveler", params, socket) do
    # UI action event name: add_traveler
    socket = dispatch_backend("add_traveler", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_booking", params, socket) do
    # UI action event name: submit_booking
    socket = dispatch_backend("submit_booking", params, socket)
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
          get_in(socket.assigns, [:null, :id]) ||
          get_in(socket.assigns, [:null, "id"])
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

  defp __apply_transitions(_event, _params, assigns), do: %{assigns: assigns, effects: []}

  def render(assigns) do
    ~H"""
    <.page title="填写订单" id="train_booking">
      <.section layout="none" id="header_section">
        <.flex justify="between" align="center" gap={3} class="px-4 py-3 border-b bg-background" id="page_header">
          <.flex align="center" gap={3} class="flex-1 min-w-0">
            <.button variant="ghost" size="sm" phx-click="go_back">
              返回
            </.button>
            <.text as="h4" class="flex-1 min-w-0 text-lg font-semibold">
              填写订单
            </.text>
          </.flex>
        </.flex>
      </.section>
      <.section layout="none" id="summary_section">
        <.card variant="default" id="train_summary_card">
          <.card_header id="train_summary_ch">
            <.flex gap={2} align="center" direction="row" id="train_header_flex">
              <.text variant="body" weight="bold" id="train_no_text">
                <%= get_in(@offer, [:train_no]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
              </.text>
              <%= if (val = get_in(@offer, [:train_type_label])) && to_string(val) != "" do %>
                <.badge variant="outline" size="sm" id="train_type_badge">
                  <%= to_string(val) %>
                </.badge>
              <% end %>
              <%= if (val = get_in(@offer, [:selected_seat_class_name])) && to_string(val) != "" do %>
                <.badge variant="secondary" size="sm" id="seat_class_badge">
                  <%= to_string(val) %>
                </.badge>
              <% end %>
            </.flex>
          </.card_header>
          <.card_content id="train_summary_cc">
            <.flex justify="between" align="center" direction="row" id="train_route_flex">
              <.stack gap={0} align="center" direction="column" id="train_departure_stack">
                <.text variant="h2" weight="bold" id="train_departure_time">
                  <%= get_in(@offer, [:departure_time]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.text>
                <.text variant="caption" color="muted" id="train_departure_station">
                  <%= get_in(@offer, [:departure_station_name]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.text>
              </.stack>
              <.stack gap={0} align="center" direction="column" id="train_middle_stack">
                <.text variant="caption" color="muted" id="train_date_label">
                  <%= get_in(@offer, [:date_label]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.text>
                <.icon name="arrow-right" size="sm" id="arrow_icon" />
              </.stack>
              <.stack gap={0} align="center" direction="column" id="train_arrival_stack">
                <.text variant="h2" weight="bold" id="train_arrival_time">
                  <%= get_in(@offer, [:arrival_time]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.text>
                <.text variant="caption" color="muted" id="train_arrival_station">
                  <%= get_in(@offer, [:arrival_station_name]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                </.text>
              </.stack>
            </.flex>
          </.card_content>
          <.card_footer id="train_summary_cf">
            <.flex justify="end" align="baseline" direction="row" id="train_price_flex">
              <.text variant="caption" id="train_currency">
                <%= get_in(@offer, [:currency]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
              </.text>
              <.text variant="h2" color="primary" id="train_seat_price">
                <%= get_in(@offer, [:selected_seat_price]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
              </.text>
            </.flex>
          </.card_footer>
        </.card>
      </.section>
      <.section layout="none" id="policy_alert_section">
        <%= if get_in(@offer, [:is_policy_exceeded]) == true do %>
          <.alert variant="warning" title="超出差旅标准" description="该席别超出您的差旅标准,提交后需经审批" id="train_policy_alert" />
        <% end %>
      </.section>
      <.section layout="none" id="traveler_section">
        <.card variant="default" id="rider_card">
          <.card_header id="rider_ch">
            <.flex justify="between" align="center" direction="row" id="rider_header_flex">
              <.text variant="h4" weight="bold" id="rider_title">
                乘车人
              </.text>
              <.button variant="ghost" size="sm" phx-click="add_traveler" id="btn_add_rider">
                + 添加
              </.button>
            </.flex>
          </.card_header>
          <.card_content id="rider_cc">
            <.stack gap={2} direction="column" id="rider_list_stack">
              <%= for item <- (get_in(@travelers, [:items]) || []) do %>
                <.flex gap={2} align="center" paddingy={2} direction="row" id="rider_item_flex">
                  <.checkbox bind="item.selected" size="md" id="rider_cb" />
                  <.avatar src={get_in(item, [:avatar])} fallback={get_in(item, [:name_initial])} size="sm" id="rider_avatar">

                  </.avatar>
                  <.stack gap={0} direction="column" id="rider_info_stack">
                    <.text variant="body" id="rider_name">
                      <%= get_in(item, [:name]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                    <.text variant="caption" color="muted" id="rider_id_label">
                      <%= get_in(item, [:id_type_label]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                </.flex>
              <% end %>
            </.stack>
          </.card_content>
        </.card>
      </.section>
      <.section layout="none" id="contact_section">
        <.card variant="default" id="contact_card">
          <.card_header id="contact_ch">
            <.text variant="h4" weight="bold" id="contact_title">
              联系人
            </.text>
          </.card_header>
          <.card_content id="contact_cc">
            <.stack gap={3} direction="column" id="contact_stack">
              <.input label="联系人姓名" placeholder="请输入联系人姓名" size="md" name="form[contact_name]" id="input_contact_name" />
              <.input label="手机号" placeholder="请输入手机号" size="md" name="form[contact_phone]" id="input_contact_phone" />
            </.stack>
          </.card_content>
        </.card>
      </.section>
      <.section layout="none" id="extra_options_section">
        <.card variant="default" id="seat_pref_card">
          <.card_header id="seat_pref_ch">
            <.text variant="h4" weight="bold" id="seat_pref_title">
              选座偏好
            </.text>
          </.card_header>
          <.card_content id="seat_pref_cc">
            <.select label="座位偏好" size="md" name="form[seat_preference]" id="select_seat_preference" :let={builder}>
              <.select_trigger builder={builder} />
              <.select_content builder={builder}>
                <.select_group>
                  <.select_item builder={builder} value="no_preference" label="无偏好">无偏好</.select_item>
                  <.select_item builder={builder} value="window" label="靠窗">靠窗</.select_item>
                  <.select_item builder={builder} value="aisle" label="靠过道">靠过道</.select_item>
                </.select_group>
              </.select_content>
            </.select>
          </.card_content>
        </.card>
      </.section>
      <.section layout="none" id="payment_section">
        <.card variant="default" id="payment_card">
          <.card_header id="payment_ch">
            <.text variant="h4" weight="bold" id="payment_title">
              支付方式
            </.text>
          </.card_header>
          <.card_content id="payment_cc">
            <.select label="选择支付方式" size="md" name="form[payment_method]" id="select_payment_method" :let={builder}>
              <.select_trigger builder={builder} />
              <.select_content builder={builder}>
                <.select_group>
                  <.select_item builder={builder} value="corporate" label="企业支付">企业支付</.select_item>
                  <.select_item builder={builder} value="personal" label="个人支付">个人支付</.select_item>
                </.select_group>
              </.select_content>
            </.select>
          </.card_content>
        </.card>
      </.section>
      <.section layout="none" id="submit_bar_section">
        <.control_bar position="sticky_bottom" id="submit_bar">
          <.flex justify="between" align="center" direction="row" id="submit_bar_flex">
            <.flex gap={1} align="baseline" direction="row" id="price_flex">
              <.text variant="caption" id="total_label">
                合计
              </.text>
              <.text variant="caption" color="primary" id="total_currency">
                <%= get_in(@offer, [:currency]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
              </.text>
              <.text variant="h2" color="primary" id="total_price">
                <%= get_in(@offer, [:total_price]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
              </.text>
            </.flex>
            <.button variant="primary" size="lg" phx-click="submit_booking" id="btn_submit">
              提交订单
            </.button>
          </.flex>
        </.control_bar>
      </.section>
    </.page>
    """
  end
end
