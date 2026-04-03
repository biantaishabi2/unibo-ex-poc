defmodule UniboExPocWeb.Pages.Travel.HomeLive do
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

  @page_id "home"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): announcements, announcements[], announcements[].publish_at, announcements[].summary, announcements[].title, hero_action_label, hero_subtitle, hero_title, message_count, pending_count, schedule_count, shortcut_1_desc, shortcut_1_icon, shortcut_1_label, shortcut_2_desc, shortcut_2_icon, shortcut_2_label, shortcut_3_desc, shortcut_3_icon, shortcut_3_label, shortcut_4_desc, shortcut_4_icon, shortcut_4_label
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"hero_title\": \"欢迎使用\",
  \"hero_subtitle\": \"便捷管理,高效协作\",
  \"hero_action_label\": \"立即开始\",
  \"shortcut_1_icon\": \"file\",
  \"shortcut_1_label\": \"功能一\",
  \"shortcut_1_desc\": \"\",
  \"shortcut_2_icon\": \"settings\",
  \"shortcut_2_label\": \"功能二\",
  \"shortcut_2_desc\": \"\",
  \"shortcut_3_icon\": \"bell\",
  \"shortcut_3_label\": \"功能三\",
  \"shortcut_3_desc\": \"\",
  \"shortcut_4_icon\": \"user\",
  \"shortcut_4_label\": \"功能四\",
  \"shortcut_4_desc\": \"\",
  \"pending_count\": 0,
  \"message_count\": 0,
  \"schedule_count\": 0,
  \"announcements\": [
    {
      \"title\": \"\",
      \"summary\": \"\",
      \"publish_at\": \"\"
    },
    {
      \"title\": \"\",
      \"summary\": \"\",
      \"publish_at\": \"\"
    },
    {
      \"title\": \"\",
      \"summary\": \"\",
      \"publish_at\": \"\"
    }
  ]
}")
  # NOTE: we atomize at runtime (mount/3) and store the result in assigns.__status_defaults.

  # Backend dispatch contract (Layer-2 behavior): mode + API placeholders.
  @backend_mode "api"
  @backend_mod UniboExPocWeb.Graphql.StitchBackend
  @runtime_config_mod UniboExPocWeb.Graphql.RuntimeConfig
  @backend_fun :dispatch
  @backend_load_event "list"
  @backend_load_selection "id"
  @backend_load_assigns %{}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{
    "list" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelOrder.list"}
  }
  @backend_embedded_page %{page_id: "home", page_kind: "list", api_map: %{list: "Travel.TravelOrder.list"}, backend: %{load: %{selection: "id"}}, route: %{path: "/pages/travel/home", query: "", kind: "list"}, state_schema: %{defaults: %{hero_title: "欢迎使用", hero_subtitle: "便捷管理,高效协作", hero_action_label: "立即开始", shortcut_1_icon: "file", shortcut_1_label: "功能一", shortcut_1_desc: "", shortcut_2_icon: "settings", shortcut_2_label: "功能二", shortcut_2_desc: "", shortcut_3_icon: "bell", shortcut_3_label: "功能三", shortcut_3_desc: "", shortcut_4_icon: "user", shortcut_4_label: "功能四", shortcut_4_desc: "", pending_count: 0, message_count: 0, schedule_count: 0, announcements: [%{title: "", summary: "", publish_at: ""}, %{title: "", summary: "", publish_at: ""}, %{title: "", summary: "", publish_at: ""}]}}, status_keys: []}
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
  def handle_event("hero_action", params, socket) do
    # UI action event name: hero_action
    socket = dispatch_backend("hero_action", params, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("navigate_announcements", params, socket) do
    # UI action event name: navigate_announcements
    socket = dispatch_backend("navigate_announcements", params, socket)
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
    <.page title="概览面板" id="home">
      <.section layout="none" id="kpi_cards">
        <.card background="primary" padding={6} variant="default" id="hero_card">
          <.card_content id="hero_content">
            <.stack align="center" gap={3} direction="column" id="hero_info">
              <.text variant="h1" weight="bold" color="white" id="hero_title">
                <%= @hero_title %>
              </.text>
              <.text variant="body" color="white" id="hero_subtitle">
                <%= @hero_subtitle %>
              </.text>
              <.button variant="secondary" phx-click="hero_action" size="md" id="hero_action">
                <%= @hero_action_label %>
              </.button>
            </.stack>
          </.card_content>
        </.card>
      </.section>
      <.section layout="grid" columns={2} id="charts">
        <.grid columns={4} gap={4} id="shortcuts">
          <.card variant="default" id="shortcut_1">
            <.card_content id="shortcut_1_content">
              <.stack align="center" gap={2} direction="column" id="shortcut_1_info">
                <.icon name={@shortcut_1_icon} size="lg" id="shortcut_1_icon" />
                <.text weight="bold" id="shortcut_1_label">
                  <%= @shortcut_1_label %>
                </.text>
                <.text variant="muted" id="shortcut_1_desc">
                  <%= @shortcut_1_desc %>
                </.text>
              </.stack>
            </.card_content>
          </.card>
          <.card variant="default" id="shortcut_2">
            <.card_content id="shortcut_2_content">
              <.stack align="center" gap={2} direction="column" id="shortcut_2_info">
                <.icon name={@shortcut_2_icon} size="lg" id="shortcut_2_icon" />
                <.text weight="bold" id="shortcut_2_label">
                  <%= @shortcut_2_label %>
                </.text>
                <.text variant="muted" id="shortcut_2_desc">
                  <%= @shortcut_2_desc %>
                </.text>
              </.stack>
            </.card_content>
          </.card>
          <.card variant="default" id="shortcut_3">
            <.card_content id="shortcut_3_content">
              <.stack align="center" gap={2} direction="column" id="shortcut_3_info">
                <.icon name={@shortcut_3_icon} size="lg" id="shortcut_3_icon" />
                <.text weight="bold" id="shortcut_3_label">
                  <%= @shortcut_3_label %>
                </.text>
                <.text variant="muted" id="shortcut_3_desc">
                  <%= @shortcut_3_desc %>
                </.text>
              </.stack>
            </.card_content>
          </.card>
          <.card variant="default" id="shortcut_4">
            <.card_content id="shortcut_4_content">
              <.stack align="center" gap={2} direction="column" id="shortcut_4_info">
                <.icon name={@shortcut_4_icon} size="lg" id="shortcut_4_icon" />
                <.text weight="bold" id="shortcut_4_label">
                  <%= @shortcut_4_label %>
                </.text>
                <.text variant="muted" id="shortcut_4_desc">
                  <%= @shortcut_4_desc %>
                </.text>
              </.stack>
            </.card_content>
          </.card>
        </.grid>
        <.card variant="default" id="announcement_card">
          <.card_header id="announcement_header">
            <.flex justify="between" align="center" direction="row" id="announcement_title_bar">
              <.card_title id="announcement_title">
                通知公告
              </.card_title>
              <.button variant="link" phx-click="navigate_announcements" size="md" id="announcement_more">
                查看更多
              </.button>
            </.flex>
          </.card_header>
          <.card_content id="announcement_content">
            <.stack gap={3} direction="column" id="announcement_list">
              <%= for ann <- (@announcements || []) do %>
                <.flex justify="between" align="center" direction="row" id="announcement_item">
                  <.stack gap={0} direction="column" id="ann_info">
                    <.text weight="bold" id="ann_title">
                      <%= get_in(ann, [:title]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                    <.text variant="muted" id="ann_summary">
                      <%= get_in(ann, [:summary]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.text variant="caption" id="ann_date">
                    <%= get_in(ann, [:publish_at]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                  </.text>
                </.flex>
              <% end %>
            </.stack>
          </.card_content>
        </.card>
      </.section>
      <.section layout="none" id="activity_feed">
        <.grid columns={3} gap={4} id="summary_grid">
          <.card variant="default" id="pending_card">
            <.card_content id="pending_content">
              <.stack align="center" gap={1} direction="column" id="pending_info">
                <.text variant="h2" weight="bold" id="pending_value">
                  <%= @pending_count %>
                </.text>
                <.text variant="muted" id="pending_label">
                  待办事项
                </.text>
              </.stack>
            </.card_content>
          </.card>
          <.card variant="default" id="message_card">
            <.card_content id="message_content">
              <.stack align="center" gap={1} direction="column" id="message_info">
                <.text variant="h2" weight="bold" id="message_value">
                  <%= @message_count %>
                </.text>
                <.text variant="muted" id="message_label">
                  未读消息
                </.text>
              </.stack>
            </.card_content>
          </.card>
          <.card variant="default" id="schedule_card">
            <.card_content id="schedule_content">
              <.stack align="center" gap={1} direction="column" id="schedule_info">
                <.text variant="h2" weight="bold" id="schedule_value">
                  <%= @schedule_count %>
                </.text>
                <.text variant="muted" id="schedule_label">
                  今日日程
                </.text>
              </.stack>
            </.card_content>
          </.card>
        </.grid>
      </.section>
    </.page>
    """
  end
end
