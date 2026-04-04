defmodule UniboExPocWeb.Pages.Travel.TravelPolicyDetailLive do
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

  @page_id "travel_policy_detail"
  @page_title "Untitled Page"

  # status.keys preview (first ~40): editing, travel_policy, travel_policy.approval_mode, travel_policy.cabin_class_limit, travel_policy.city_tier, travel_policy.employee_level, travel_policy.exceed_strategy, travel_policy.hotel_star_limit, travel_policy.is_active, travel_policy.max_amount, travel_policy.personal_pay_ratio, travel_policy.policy_name, travel_policy.product_type, travel_policy.season
  # Defaults are used for dev/mock transitions (e.g. toggle_list_empty restore).
  @status_defaults_raw Jason.decode!("{
  \"travel_policy\": {
    \"policy_name\": \"\",
    \"product_type\": \"\",
    \"employee_level\": \"\",
    \"city_tier\": \"\",
    \"season\": \"\",
    \"max_amount\": \"\",
    \"cabin_class_limit\": \"\",
    \"hotel_star_limit\": \"\",
    \"exceed_strategy\": \"\",
    \"approval_mode\": \"\",
    \"personal_pay_ratio\": \"\",
    \"is_active\": \"\"
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
  @backend_load_selection "approval_mode: approvalMode cabin_class_limit: cabinClassLimit city_tier: cityTier employee_level: employeeLevel enterprise_id: enterpriseId exceed_strategy: exceedStrategy hotel_star_limit: hotelStarLimit id is_active: isActive max_amount: maxAmount personal_pay_ratio: personalPayRatio policy_name: policyName product_type: productType season"
  @backend_load_assigns %{travel_policy: %{}}
  @backend_params_accept ["id", "enterprise_id", "max_amount", "cabin_class_limit", "policy_name", "approval_mode", "season", "product_type", "employee_level", "hotel_star_limit", "exceed_strategy", "personal_pay_ratio", "city_tier"]
  @backend_info_reload_messages []
  @backend_api_map %{
    "activate" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelPolicy.activate"},
    "create" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelPolicy.create"},
    "deactivate" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelPolicy.deactivate"},
    "get" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelPolicy.get"},
    "update" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelPolicy.update"}
  }
  @backend_embedded_page %{page_id: "travel_policy_detail", page_kind: "detail", api_map: %{activate: "Travel.TravelPolicy.activate", create: "Travel.TravelPolicy.create", deactivate: "Travel.TravelPolicy.deactivate", get: "Travel.TravelPolicy.get", update: "Travel.TravelPolicy.update"}, backend: %{load: %{selection: "approval_mode: approvalMode cabin_class_limit: cabinClassLimit city_tier: cityTier employee_level: employeeLevel enterprise_id: enterpriseId exceed_strategy: exceedStrategy hotel_star_limit: hotelStarLimit id is_active: isActive max_amount: maxAmount personal_pay_ratio: personalPayRatio policy_name: policyName product_type: productType season"}}, route: %{path: "/pages/travel/travel_policy/:id", query: "", kind: "detail"}, state_schema: %{defaults: %{travel_policy: %{policy_name: "", product_type: "", employee_level: "", city_tier: "", season: "", max_amount: "", cabin_class_limit: "", hotel_star_limit: "", exceed_strategy: "", approval_mode: "", personal_pay_ratio: "", is_active: ""}, editing: false}}, status_keys: ["record", "editing", "form", "loading"]}
  @entity_assign_fields ["policy_name", "product_type", "employee_level", "city_tier", "season", "max_amount", "cabin_class_limit", "hotel_star_limit", "exceed_strategy", "approval_mode", "personal_pay_ratio", "is_active"]
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
          get_in(socket.assigns, [:travel_policy, :id]) ||
          get_in(socket.assigns, [:travel_policy, "id"])
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
      %{travel_policy: entity} when is_map(entity) and map_size(entity) > 0 -> assign(socket, :travel_policy, entity)
      %{record: entity} when is_map(entity) ->
        case __assign_map_present?(entity) do
          true -> assign(socket, :travel_policy, entity)
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
          entity = Map.get(socket.assigns, :travel_policy, %{})
          entity = if is_map(entity), do: Map.merge(entity, source), else: source
          assign(socket, :travel_policy, entity)
        end
    end
  end
  defp __sync_entity_assign(socket, _dto), do: socket

  defp __sync_record_alias(socket) do
    case socket.assigns do
      %{travel_policy: entity} when is_map(entity) ->
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

  defp __apply_transitions("action_activate", params, assigns) do
  assigns = assigns
  effects = []
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions("action_deactivate", params, assigns) do
  assigns = assigns
  effects = []
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

  defp __apply_transitions("action_destroy", params, assigns) do
  assigns = assigns
  effects = []
  effects = [%{type: "navigate", to: "/pages/travel/travel_policy"} | effects]
  effects = __interpolate_effects(effects, params)
  %{assigns: assigns, effects: Enum.reverse(effects)}
end

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
    <.page title="详情" id="travel_policy_detail">
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
              TravelPolicy
            </.text>
            <.text variant="h1" id="page_title">
              差旅标准政策,定义不同企业、职级、城市等级下的差旅费用上限与超标策略
            </.text>
          </.stack>
          <.badge bind="travel_policy.status" variant="default" size="sm" id="status_badge" />
        </.flex>
        <.flex gap={2} direction="row" id="actions_group">
          <.button variant="secondary" phx-click="toggle_edit" size="md" id="edit_btn">
            编辑
          </.button>
          <.button variant="secondary" phx-click="action_activate" size="md" id="travel_policy_action_activate">
            activate
          </.button>
          <.button variant="secondary" phx-click="action_deactivate" size="md" id="travel_policy_action_deactivate">
            deactivate
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
                  <.stack gap={0} direction="column" id="detail_fields_policy_name">
                    <.text variant="caption" color="muted" id="detail_fields_policy_name_label">
                      政策名称,如'总部差旅标准'
                    </.text>
                    <.text id="detail_fields_policy_name_value">
                      <%= get_in(@travel_policy, [:policy_name]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_product_type">
                    <.text variant="caption" color="muted" id="detail_fields_product_type_label">
                      适用商品类型
                    </.text>
                    <.text id="detail_fields_product_type_value">
                      <%= get_in(@travel_policy, [:product_type]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_employee_level">
                    <.text variant="caption" color="muted" id="detail_fields_employee_level_label">
                      职级标识
                    </.text>
                    <.text id="detail_fields_employee_level_value">
                      <%= get_in(@travel_policy, [:employee_level]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_city_tier">
                    <.text variant="caption" color="muted" id="detail_fields_city_tier_label">
                      城市等级（tier_1/tier_2/tier_3）
                    </.text>
                    <.text id="detail_fields_city_tier_value">
                      <%= get_in(@travel_policy, [:city_tier]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_season">
                    <.text variant="caption" color="muted" id="detail_fields_season_label">
                      淡旺季标识（可选）
                    </.text>
                    <.text id="detail_fields_season_value">
                      <%= get_in(@travel_policy, [:season]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_max_amount">
                    <.text variant="caption" color="muted" id="detail_fields_max_amount_label">
                      金额上限（单位分）
                    </.text>
                    <.text id="detail_fields_max_amount_value">
                      <%= get_in(@travel_policy, [:max_amount]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_cabin_class_limit">
                    <.text variant="caption" color="muted" id="detail_fields_cabin_class_limit_label">
                      舱位限制
                    </.text>
                    <.text id="detail_fields_cabin_class_limit_value">
                      <%= get_in(@travel_policy, [:cabin_class_limit]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_hotel_star_limit">
                    <.text variant="caption" color="muted" id="detail_fields_hotel_star_limit_label">
                      酒店星级限制
                    </.text>
                    <.text id="detail_fields_hotel_star_limit_value">
                      <%= get_in(@travel_policy, [:hotel_star_limit]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_exceed_strategy">
                    <.text variant="caption" color="muted" id="detail_fields_exceed_strategy_label">
                      超标处理策略
                    </.text>
                    <.text id="detail_fields_exceed_strategy_value">
                      <%= get_in(@travel_policy, [:exceed_strategy]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_approval_mode">
                    <.text variant="caption" color="muted" id="detail_fields_approval_mode_label">
                      审批模式;none 表示关闭审批,self/oa 表示进入对应审批流
                    </.text>
                    <.text id="detail_fields_approval_mode_value">
                      <%= get_in(@travel_policy, [:approval_mode]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_personal_pay_ratio">
                    <.text variant="caption" color="muted" id="detail_fields_personal_pay_ratio_label">
                      个人支付比例 0-100
                    </.text>
                    <.text id="detail_fields_personal_pay_ratio_value">
                      <%= get_in(@travel_policy, [:personal_pay_ratio]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                  <.stack gap={0} direction="column" id="detail_fields_is_active">
                    <.text variant="caption" color="muted" id="detail_fields_is_active_label">
                      是否启用
                    </.text>
                    <.text id="detail_fields_is_active_value">
                      <%= get_in(@travel_policy, [:is_active]) |> then(fn v when is_binary(v) and v != "" -> v; _ -> "" end) %>
                    </.text>
                  </.stack>
                </.grid>
              </.grid>
            <% else %>
              <.form for={%{}} phx-submit="form_submit" phx-change="form_change" id="travel_policy_edit_form">
                <.grid columns={2} gap={4} id="form_grid">
                  <.stack direction="column" id="form_fields">
                    <.input size="md" name="travel_policy[policy_name]" id="travel_policy_form_policy_name" value={get_in(@travel_policy, [:policy_name]) || ""} />
                    <.select size="md" name="travel_policy[product_type]" id="travel_policy_form_product_type" :let={builder} value={get_in(@travel_policy, [:product_type]) || ""}>
                      <.select_trigger builder={builder} />
                      <.select_content builder={builder}>
                        <.select_group>
                          <.select_item builder={builder} value="flight" label="flight">flight</.select_item>
                          <.select_item builder={builder} value="hotel" label="hotel">hotel</.select_item>
                          <.select_item builder={builder} value="train" label="train">train</.select_item>
                          <.select_item builder={builder} value="car" label="car">car</.select_item>
                        </.select_group>
                      </.select_content>
                    </.select>
                    <.input size="md" name="travel_policy[employee_level]" id="travel_policy_form_employee_level" value={get_in(@travel_policy, [:employee_level]) || ""} />
                    <.input size="md" name="travel_policy[city_tier]" id="travel_policy_form_city_tier" value={get_in(@travel_policy, [:city_tier]) || ""} />
                    <.input size="md" name="travel_policy[season]" id="travel_policy_form_season" value={get_in(@travel_policy, [:season]) || ""} />
                    <.input size="md" name="travel_policy[max_amount]" id="travel_policy_form_max_amount" value={get_in(@travel_policy, [:max_amount]) || ""} />
                    <.input size="md" name="travel_policy[cabin_class_limit]" id="travel_policy_form_cabin_class_limit" value={get_in(@travel_policy, [:cabin_class_limit]) || ""} />
                    <.input size="md" name="travel_policy[hotel_star_limit]" id="travel_policy_form_hotel_star_limit" value={get_in(@travel_policy, [:hotel_star_limit]) || ""} />
                    <.select size="md" name="travel_policy[exceed_strategy]" id="travel_policy_form_exceed_strategy" :let={builder} value={get_in(@travel_policy, [:exceed_strategy]) || ""}>
                      <.select_trigger builder={builder} />
                      <.select_content builder={builder}>
                        <.select_group>
                          <.select_item builder={builder} value="block" label="block">block</.select_item>
                          <.select_item builder={builder} value="require_reason" label="require_reason">require_reason</.select_item>
                          <.select_item builder={builder} value="require_approval" label="require_approval">require_approval</.select_item>
                          <.select_item builder={builder} value="personal_pay" label="personal_pay">personal_pay</.select_item>
                        </.select_group>
                      </.select_content>
                    </.select>
                    <.select size="md" name="travel_policy[approval_mode]" id="travel_policy_form_approval_mode" :let={builder} value={get_in(@travel_policy, [:approval_mode]) || ""}>
                      <.select_trigger builder={builder} />
                      <.select_content builder={builder}>
                        <.select_group>
                          <.select_item builder={builder} value="none" label="none">none</.select_item>
                          <.select_item builder={builder} value="self" label="self">self</.select_item>
                          <.select_item builder={builder} value="oa" label="oa">oa</.select_item>
                        </.select_group>
                      </.select_content>
                    </.select>
                    <.input size="md" name="travel_policy[personal_pay_ratio]" id="travel_policy_form_personal_pay_ratio" value={get_in(@travel_policy, [:personal_pay_ratio]) || ""} />
                    <.input size="md" name="travel_policy[enterprise_id]" id="travel_policy_form_enterprise_id" value={get_in(@travel_policy, [:enterprise_id]) || ""} />
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
