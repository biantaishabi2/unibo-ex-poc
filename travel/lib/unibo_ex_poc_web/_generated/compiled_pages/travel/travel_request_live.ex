defmodule UniboExPocWeb.Pages.Travel.TravelRequestLive do
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

  @page_id "travel_request"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): step_1_label, step_2_label, step_3_label
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"step_1_label\": \"基本信息\",
  \"step_2_label\": \"详细配置\",
  \"step_3_label\": \"确认提交\"
}")
  # NOTE: we atomize at runtime (mount/3) and store the result in assigns.__status_defaults.

  # Backend dispatch contract (Layer-2 behavior): mode + API placeholders.
  @backend_mode "api"
  @backend_mod UniboExPocWeb.Graphql.StitchBackend
  @runtime_config_mod UniboExPocWeb.Graphql.RuntimeConfig
  @backend_fun :dispatch
  @backend_load_event "list"
  @backend_load_selection "id"
  @backend_load_assigns %{travel_order: %{}}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{
    "create" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelOrder.create"},
    "list" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelOrder.list"}
  }
  @backend_embedded_page %{page_id: "travel_request", page_kind: "detail", api_map: %{create: "Travel.TravelOrder.create", list: "Travel.TravelOrder.list"}, backend: %{load: %{selection: "id"}}, route: %{path: "/pages/travel/travel_request", query: "", kind: "detail"}, state_schema: %{defaults: %{step_1_label: "基本信息", step_2_label: "详细配置", step_3_label: "确认提交"}}, status_keys: []}
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
  def handle_event("wizard_cancel", params, socket) do
    # UI action event name: wizard_cancel
    socket = dispatch_backend("wizard_cancel", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("wizard_next", params, socket) do
    # UI action event name: wizard_next
    socket = dispatch_backend("wizard_next", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("wizard_prev", params, socket) do
    # UI action event name: wizard_prev
    socket = dispatch_backend("wizard_prev", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("wizard_submit", params, socket) do
    # UI action event name: wizard_submit
    socket = dispatch_backend("wizard_submit", params, socket)
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
    <.page title="表单" id="travel_request">
      <.section layout="none" id="breadcrumb_section">
        <.flex direction="row" id="breadcrumb_bar" />
      </.section>
      <.section layout="none" id="header">
        <.flex justify="between" align="center" direction="row" id="wz_header_bar">
          <.stack direction="column" id="wz_page_meta">
            <.text variant="caption" color="muted" id="breadcrumb">
              TravelOrder
            </.text>
            <.text variant="h1" id="page_title">
              统一酒旅订单,承接 hotel、flight、vacation、train 四类商品的下单和状态流转;通过跨域引用关联 Sales::Customer 和 Payment::Payment
            </.text>
          </.stack>
          <.flex gap={2} direction="row" id="wz_header_actions">
            <.button variant="ghost" phx-click="wizard_cancel" size="md" id="wz_hdr_cancel_btn">
              取消
            </.button>
            <.button variant="primary" phx-click="wizard_submit" size="md" id="wz_hdr_submit_btn">
              提交
            </.button>
          </.flex>
        </.flex>
      </.section>
      <.section layout="grid" columns={4} id="form_section">
        <.flex justify="center" align="center" gap={4} direction="row" id="wz_step_bar">
          <.stack align="center" direction="column" id="wz_step_1">
            <.badge variant="default" size="sm" id="wz_step_1_indicator">
              1
            </.badge>
            <.text variant="caption" id="wz_step_1_label">
              <%= @step_1_label %>
            </.text>
          </.stack>
          <.text variant="muted" id="wz_step_sep_1">
            —
          </.text>
          <.stack align="center" direction="column" id="wz_step_2">
            <.badge variant="default" size="sm" id="wz_step_2_indicator">
              2
            </.badge>
            <.text variant="caption" id="wz_step_2_label">
              <%= @step_2_label %>
            </.text>
          </.stack>
          <.text variant="muted" id="wz_step_sep_2">
            —
          </.text>
          <.stack align="center" direction="column" id="wz_step_3">
            <.badge variant="default" size="sm" id="wz_step_3_indicator">
              3
            </.badge>
            <.text variant="caption" id="wz_step_3_label">
              <%= @step_3_label %>
            </.text>
          </.stack>
        </.flex>
        <.card variant="default" id="wz_step_1_card">
          <.card_header id="wz_step_1_header">
            <.card_title id="wz_step_1_title">
              <%= @step_1_label %>
            </.card_title>
          </.card_header>
          <.card_content id="wz_step_1_content">
            <.stack direction="column" id="wz_step_1_grid">
              <.input size="md" name="travel_order[tenant_id]" id="form_tenant_id" />
              <.input size="md" name="travel_order[host_shop_id]" id="form_host_shop_id" />
              <.input size="md" name="travel_order[order_no]" id="form_order_no" />
              <.select size="md" name="travel_order[product_type]" id="form_product_type" :let={builder}>
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
              <.input size="md" name="travel_order[customer_id]" id="form_customer_id" />
              <.input size="md" name="travel_order[contact_name]" id="form_contact_name" />
              <.input size="md" name="travel_order[contact_phone]" id="form_contact_phone" />
              <.input size="md" name="travel_order[traveler_count]" id="form_traveler_count" />
              <.input size="md" name="travel_order[total_amount]" id="form_total_amount" />
              <.input size="md" name="travel_order[points_to_use]" id="form_points_to_use" />
              <.input size="md" name="travel_order[points_deduction_amount]" id="form_points_deduction_amount" />
              <.input size="md" name="travel_order[currency]" id="form_currency" />
              <.input size="md" name="travel_order[ticket_passenger_infos]" id="form_ticket_passenger_infos" />
              <.input columns={2} gap={4} size="md" name="travel_order[seat_selection_snapshot]" id="form_seat_selection_snapshot" />
            </.stack>
          </.card_content>
        </.card>
        <.card variant="default" id="wz_step_2_card">
          <.card_header id="wz_step_2_header">
            <.card_title id="wz_step_2_title">
              <%= @step_2_label %>
            </.card_title>
          </.card_header>
          <.card_content id="wz_step_2_content">
            <.grid columns={2} gap={4} id="wz_step_2_grid" />
          </.card_content>
        </.card>
        <.card variant="default" id="wz_step_3_card">
          <.card_header id="wz_step_3_header">
            <.card_title id="wz_step_3_title">
              <%= @step_3_label %>
            </.card_title>
          </.card_header>
          <.card_content id="wz_step_3_content">
            <.stack gap={3} direction="column" id="wz_summary_display">
              <.text id="wz_summary_fields">
                汇总确认区域
              </.text>
            </.stack>
          </.card_content>
        </.card>
      </.section>
      <.section layout="none" id="form_footer">
        <.flex justify="between" direction="row" id="wz_nav_buttons">
          <.button variant="secondary" phx-click="wizard_prev" size="md" id="wz_prev_btn">
            上一步
          </.button>
          <.flex gap={2} direction="row" id="wz_right_buttons">
            <.button variant="ghost" phx-click="wizard_cancel" size="md" id="wz_cancel_btn">
              取消
            </.button>
            <.button variant="primary" phx-click="wizard_next" size="md" id="wz_next_btn">
              下一步
            </.button>
            <.button variant="primary" phx-click="wizard_submit" size="md" id="wz_submit_btn">
              提交
            </.button>
          </.flex>
        </.flex>
      </.section>
    </.page>
    """
  end
end
