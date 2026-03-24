defmodule MyAppWeb.Pages.StitchGeneratedLive do
  @moduledoc """
  Auto-generated LiveView skeleton (dev-only).

  - Event names come from UI action semantics (events.schema).
  - Backend API names are placeholders by design; wire them to real services later.
  """

  use MyAppWeb, :live_view

  @page_id "MyAppWeb.Pages.StitchGeneratedLive"
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
  @backend_mod __MODULE__.Backend
  @backend_fun :handle_event
  @backend_load_event nil
  @backend_load_selection nil
  @backend_load_assigns %{}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{}
  @status_key_roots []
  @auth_mode "optional"
  @user_context_assigns []

  @impl true
  def mount(params, _session, socket) do
    socket = ensure_user_context(socket)
    socket = assign(socket, :page_title, @page_title)
    defaults = atomize_keys(@status_defaults_raw)
    socket = assign(socket, defaults)
    socket = assign(socket, :__status_defaults, defaults)
    socket = if is_map(@backend_load_assigns) and map_size(@backend_load_assigns) > 0, do: assign(socket, @backend_load_assigns), else: socket
    socket = apply_derived(socket)
    socket = apply_params(socket, params)
    backend_params = __filter_backend_params(params)
    socket = if @backend_mode == "api" and is_binary(@backend_load_event), do: dispatch_backend(@backend_load_event, Map.put(backend_params, "__page_id", @page_id), socket), else: socket
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = __maybe_assign_self_path(socket, _uri)
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
    result =
      case @backend_mode do
        "transitions" ->
          state0 = __take_status(socket.assigns)
          %{assigns: assigns2, effects: effects} = __apply_transitions(event, params, state0)
          {dto, st} = __split_dto_status(assigns2)
          {:ok, %{dto: dto, status: st, effects: effects, errors: [], meta: %{mode: "transitions"}}}
        "api" ->
          _mapping = Map.get(@backend_api_map, event)
          state0 = __take_status(socket.assigns)
          apply(@backend_mod, @backend_fun, [event, params, state0])
      end

    apply_backend_result(socket, result)
  end

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
    socket |> assign(assigns) |> assign(:_dto, assigns) |> assign(:_status, %{})
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

  defmodule Backend do
    @moduledoc false
    # Default no-op backend: keeps the skeleton runnable in mock/dev.
    def handle_event(_event, _params, assigns), do: {:ok, %{dto: assigns, status: %{}, effects: [], errors: [], meta: %{}}}
  end

  defp apply_derived(socket), do: socket

  defp __apply_transitions(_event, _params, assigns), do: %{assigns: assigns, effects: []}

  def render(assigns) do
    # Convention: the compiled HEEx lives in a sibling function component module.
    # Replace only backend API placeholders; render wiring stays stable.
    MyAppWeb.Pages.StitchGeneratedLive.HEEx.render(assigns)
  end
end
