defmodule UniboExPocWeb.Pages.Travel.AuthRoleDetailLive do
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

  @page_id "auth_role_detail"
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
  # compiled 模式：直连 GraphQL，不再经过 StitchBackend
  @runtime_config_mod UniboExPocWeb.Graphql.RuntimeConfig
  @backend_load_event "get"
  @backend_load_selection "id"
  @backend_load_assigns %{travel_policy: %{}}
  @backend_params_accept []
  @backend_info_reload_messages []
  @backend_api_map %{
    "get" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelPolicy.get"},
    "list" => %{module: UniboExPocWeb.Graphql.StitchBackend, fun: :dispatch, api: "Travel.TravelPolicy.list"}
  }
  @graphql_field_map %{"get" => "get_travel_travel_policy", "list" => "list_travel_travel_policys"}
  @input_allowlist %{}
  @input_type_name_map %{}
  @input_type_map %{}
  @entity_assign_fields ["policy_name", "product_type", "employee_level", "city_tier", "season", "max_amount", "cabin_class_limit", "hotel_star_limit", "exceed_strategy", "approval_mode", "personal_pay_ratio", "is_active"]
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
          get_in(socket.assigns, [:travel_policy, :id]) || get_in(socket.assigns, [:travel_policy, "id"])
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
    type_map = Map.get(@input_type_map, action, %{})
    params
    |> Map.drop(["id", :id, "_target", "__page_id", "_csrf_token"])
    |> __extract_compiled_entity_input()
    |> Map.take(allowlist)
    |> __coerce_types(type_map)
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
      get_in(socket.assigns, [:travel_policy, :id]) ||
      get_in(socket.assigns, [:travel_policy, "id"]) ||
      (socket.assigns[:record] && socket.assigns[:record]["id"]) ||
      (socket.assigns[:travel_policy] && socket.assigns[:travel_policy]["id"]) || ""
  end

  defp __coerce_types(input, type_map) when is_map(input) and is_map(type_map) do
    Map.new(input, fn {k, v} ->
      case Map.get(type_map, k) do
        "integer" when is_binary(v) ->
          case Integer.parse(v) do
            {n, ""} -> {k, n}
            _ -> {k, v}
          end
        "decimal" when is_binary(v) -> {k, v}
        "boolean" when is_binary(v) -> {k, v == "true"}
        "float" when is_binary(v) ->
          case Float.parse(v) do
            {n, ""} -> {k, n}
            _ -> {k, v}
          end
        _ -> {k, v}
      end
    end)
  end
  defp __coerce_types(input, _), do: input

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
    <.page title="详情" id="auth_role_detail">
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
