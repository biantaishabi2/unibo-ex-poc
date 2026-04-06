defmodule UniboExPocWeb.Generated.PageHostRuntime do
  @moduledoc """
  通用页面宿主运行时（由 UniBO 自动生成）。

  负责：
  - `frontend_manifest.v1.json` / `route_map` 消费
  - `mock/graphql` runtime 切换
  - 页面模板、状态默认值、mock 数据装载
  - backend dispatch 与 effects 归一化
  """

  alias UniboExPocWeb.Graphql.RuntimeConfig

  @load_event "__load__"
  @default_assigns %{page_title: "", flash_preview: %{}}

  def default_assigns, do: @default_assigns

  def load_page(page_id, params, runtime_mode \\ runtime_mode(), backend \\ page_backend())

  def load_page(page_id, params, runtime_mode, backend) when is_binary(page_id) do
    with {:ok, page} <- RuntimeConfig.frontend_page(page_id),
         {:ok, path, content} <- page_template(page_id, page),
         {:ok, page_data} <- load_page_data(path, page_id, page, params, runtime_mode, backend) do
      {:ok, %{page: page, path: path, content: content, page_data: page_data}}
    end
  end

  def load_page(_page_id, _params, _runtime_mode, _backend),
    do: {:error, :page_host_page_not_found}

  def resolve_host_route(route_segments) when is_list(route_segments),
    do: resolve_host_route(route_segments, %{})

  def resolve_host_route(route_path) when is_binary(route_path),
    do: resolve_host_route(route_path, %{})

  def resolve_host_route(_route), do: {:error, :page_host_page_not_found}

  def resolve_host_route(route_segments, query_params)
      when is_list(route_segments) and is_map(query_params) do
    route_segments =
      route_segments
      |> Enum.map(&normalize_string/1)
      |> Enum.reject(&(&1 == ""))

    path =
      case route_segments do
        [] -> nil
        values -> "/" <> Enum.join(values, "/")
      end

    cond do
      path in [nil, ""] ->
        {:error, :page_host_page_not_found}

      true ->
        resolve_host_route_path(path, query_params)
    end
  end

  def resolve_host_route(route_path, query_params)
      when is_binary(route_path) and is_map(query_params) do
    route_path
    |> normalize_string()
    |> case do
      "" -> {:error, :page_host_page_not_found}
      path ->
        if String.starts_with?(path, "/") do
          resolve_host_route_path(path, query_params)
        else
          resolve_host_route_path("/" <> path, query_params)
        end
    end
  end

  def resolve_host_route(_route_segments, _query_params), do: {:error, :page_host_page_not_found}

  def dispatch(backend, page_id, event, params, state)
      when is_atom(backend) and is_binary(page_id) and is_binary(event) and is_map(params) and
             is_map(state) do
    case Code.ensure_loaded(backend) do
      {:module, _module} ->
        if function_exported?(backend, :dispatch, 3) do
          backend.dispatch(
            event,
            %{"__page_id" => page_id} |> Map.merge(stringify_map(params)),
            stringify_map(state)
          )
        else
          {:error, :page_backend_not_available}
        end

      _ ->
        {:error, :page_backend_not_available}
    end
  end

  def dispatch(_backend, _page_id, _event, _params, _state),
    do: {:error, :page_backend_not_available}

  def merge_backend_payload(page_data, dto, status) do
    page_data
    |> deep_merge(deep_existing_atomize_keys(normalize_map(dto)))
    |> deep_merge(deep_existing_atomize_keys(normalize_map(status)))
  end

  def maybe_put_flash_from_effects(page_data, effects) do
    case Enum.find(normalize_effects(effects), &match?(%{type: "flash"}, &1)) do
      %{kind: kind, message: message} ->
        Map.put(page_data, :flash_preview, %{kind: kind, message: message})

      _ ->
        page_data
    end
  end

  def normalize_effects(effects) when is_list(effects) do
    Enum.map(effects, fn effect ->
      effect
      |> normalize_map()
      |> deep_generated_atomize_keys()
    end)
  end

  def normalize_effects(_effects), do: []

  def runtime_mode, do: RuntimeConfig.page_host_runtime()
  def page_backend, do: RuntimeConfig.page_host_backend()
  def pages_dir, do: RuntimeConfig.page_host_pages_dir()
  def host_prefix, do: RuntimeConfig.page_host_prefix()
  def host_index_path, do: host_prefix()
  def default_tenant_id, do: RuntimeConfig.default_tenant_id()

  def list_pages do
    case manifest_pages() do
      [] -> list_pages_from_directory()
      pages -> pages
    end
  end

  def page_contract(page_id) when is_binary(page_id) do
    case RuntimeConfig.frontend_page(page_id) do
      {:ok, page} ->
        case page_template(page_id, page) do
          {:ok, path, _content} -> load_behavior_contract(path)
          _ -> %{}
        end

      _ ->
        %{}
    end
  end

  def page_contract(_page_id), do: %{}

  @doc "从 manifest transitions 查找事件的 navigate_to 目标"
  def event_navigate_to(page_id, event_name, params \\ %{}) when is_binary(page_id) and is_binary(event_name) do
    with {:ok, page} <- RuntimeConfig.frontend_page(page_id) do
      transitions = map_get(page, "transitions") |> normalize_list()
      case Enum.find(transitions, fn t -> normalize_string(map_get(t, "name")) == event_name end) do
        %{} = transition ->
          case normalize_string(map_get(transition, "navigate_to")) do
            "" -> :none
            target ->
              resolved = Regex.replace(~r/\{(\w+)\}/, target, fn _full, key ->
                normalize_string(Map.get(params, key, Map.get(params, String.to_atom(key), "")))
              end)
              {:ok, resolved}
          end
        nil -> :none
      end
    else
      _ -> :none
    end
  end

  @doc "按 page_id + params 反向生成 host 路由"
  def host_route_for_page(page_id, params \\ %{}) when is_binary(page_id) and is_map(params) do
    route_map = RuntimeConfig.frontend_route_map()

    case Enum.find(route_map, fn route ->
           normalize_string(route |> map_get("page_id")) == page_id
         end) do
      nil ->
        normalize_host_target(page_id, page_id)

      route ->
        route_path = route |> map_get("path") |> normalize_string()
        full_path = route |> map_get("full_path") |> normalize_string()
        route_query = route |> map_get("query") |> normalize_string()
        primary_path = primary_route_path(route_path, full_path)

        path =
          primary_path
          |> interpolate_route_path(params)
          |> case do
            "" -> "/" <> page_id
            value -> value
          end

        query = interpolate_route_query(route_query, params)
        target = if query == "", do: path, else: path <> "?" <> query
        normalize_host_target(target, page_id)
    end
  end

  @doc "页面是否有非空 api_map（即是否需要走 backend dispatch）"
  def page_has_backend?(page_id) when is_binary(page_id) do
    case RuntimeConfig.frontend_page(page_id) do
      {:ok, page} -> normalize_map(map_get(page, "api_map")) != %{}
      _ -> false
    end
  end

  def page_has_backend?(_page_id), do: false

  def host_path_for_page(page) when is_map(page) do
    page
    |> map_get("host_route")
    |> case do
      nil -> page |> map_get("route")
      value -> value
    end
    |> normalize_host_target(page |> map_get("page_id") |> normalize_string())
  end

  def normalize_host_target(target, fallback \\ "")

  def normalize_host_target(target, fallback) when is_binary(target) do
    prefix = host_prefix()
    normalized_fallback = normalize_string(fallback)

    normalized =
      case normalize_string(target) do
        "" -> normalized_fallback
        value -> value
      end

    cond do
      normalized == "" ->
        prefix

      String.starts_with?(normalized, prefix) ->
        normalized

      String.starts_with?(normalized, "/") ->
        prefix <> normalized

      true ->
        prefix <> "/" <> normalized
    end
  end

  def normalize_host_target(_target, fallback), do: normalize_host_target("", fallback)

  defp interpolate_route_path(path, params) when is_binary(path) and is_map(params) do
    Regex.replace(~r/:([a-zA-Z0-9_]+)/, path, fn _full, key ->
      normalize_string(Map.get(params, key, Map.get(params, String.to_atom(key), "")))
    end)
  end

  defp interpolate_route_path(path, _params), do: normalize_string(path)

  defp interpolate_route_query(query, params) when is_binary(query) and is_map(params) do
    Regex.replace(~r/\{\{\s*([^}]+?)\s*\}\}/, query, fn _full, key ->
      normalize_string(Map.get(params, key, Map.get(params, String.to_atom(key), "")))
    end)
  end

  defp interpolate_route_query(query, _params), do: normalize_string(query)

  def normalize_map(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} -> {key, value}
    end)
  end

  def normalize_map(_map), do: %{}

  def stringify_map(value) when is_map(value) do
    Enum.into(value, %{}, fn {key, val} ->
      string_key =
        cond do
          is_atom(key) -> Atom.to_string(key)
          is_binary(key) -> key
          true -> to_string(key)
        end

      {string_key, stringify_map(val)}
    end)
  end

  def stringify_map(value) when is_list(value), do: Enum.map(value, &stringify_map/1)
  def stringify_map(value), do: value

  def normalize_list(values) when is_list(values), do: values
  def normalize_list(_values), do: []

  def normalize_string_list(values) when is_list(values) do
    values
    |> Enum.map(&normalize_string/1)
    |> Enum.reject(&(&1 == ""))
  end

  def normalize_string_list(_values), do: []

  def normalize_string(nil), do: ""
  def normalize_string(value) when is_binary(value), do: String.trim(value)
  def normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  def normalize_string(value), do: value |> to_string() |> String.trim()

  def map_get(map, key) when is_map(map) and is_atom(key), do: map_get(map, Atom.to_string(key))

  def map_get(map, key) when is_map(map) and is_binary(key) do
    Enum.find_value(map, fn
      {existing_key, value} when is_binary(existing_key) and existing_key == key ->
        value

      {existing_key, value} when is_atom(existing_key) ->
        if Atom.to_string(existing_key) == key, do: value, else: nil

      _ ->
        nil
    end)
  end

  def map_get(_map, _key), do: nil

  def normalize_page_params(page_id, params) when is_binary(page_id) and is_map(params) do
    params = stringify_map(params)
    route_id = map_get(params, "id") |> normalize_string()

    accepted =
      page_id
      |> page_contract()
      |> map_get("backend")
      |> map_get("params")
      |> map_get("accept")
      |> normalize_string_list()

    case accepted do
      [] ->
        maybe_put_route_id(params, route_id)

      values ->
        allowed = Enum.uniq(["id" | values])

        params
        |> Map.take(allowed)
        |> maybe_put_route_id(route_id)
        |> maybe_restore_original_params(params)
    end
  end

  def normalize_page_params(_page_id, params) when is_map(params), do: stringify_map(params)
  def normalize_page_params(_page_id, _params), do: %{}

  def supports_reload?(page_id) when is_binary(page_id) do
    messages =
      page_id
      |> page_contract()
      |> map_get("backend")
      |> map_get("info")
      |> map_get("reload_messages")
      |> normalize_string_list()

    messages == [] or "page_host_reload" in messages
  end

  def supports_reload?(_page_id), do: false

  defp maybe_put_route_id(params, ""), do: params
  defp maybe_put_route_id(params, id), do: Map.put(params, "id", id)

  defp maybe_restore_original_params(%{} = normalized, %{} = original)
       when map_size(normalized) == 0 and map_size(original) > 0,
       do: original

  defp maybe_restore_original_params(normalized, _original), do: normalized

  defp resolve_host_route_path(path, query_params) do
    normalized_path = normalize_route_lookup_path(path)
    route_map = RuntimeConfig.frontend_route_map()

    exact_match =
      Enum.find_value(route_map, fn route ->
        match_route(route, path, normalized_path, query_params, :exact)
      end)

    pattern_match =
      Enum.find_value(route_map, fn route ->
        match_route(route, path, normalized_path, query_params, :pattern)
      end)

    case exact_match || pattern_match do
      %{} = resolved ->
        {:ok, resolved}

      _ ->
        page_id =
          normalized_path
          |> String.trim_leading("/")
          |> normalize_string()

        case RuntimeConfig.frontend_page(page_id) do
          {:ok, _page} ->
            {:ok, %{page_id: page_id, page_params: %{}, route_path: normalized_path}}

          _ ->
            {:error, :page_host_page_not_found}
        end
    end
  end

  defp match_route(route, current_path, normalized_path, query_params, mode) do
    route_path = route |> map_get("path") |> normalize_string()
    full_path = route |> map_get("full_path") |> normalize_string()
    route_query = route |> map_get("query") |> normalize_string()
    page_id = route |> map_get("page_id") |> normalize_string()
    primary_path = primary_route_path(route_path, full_path)
    candidates = [route_path, full_path] |> Enum.filter(&(&1 != "")) |> Enum.uniq()

    cond do
      primary_path == "" or page_id == "" ->
        nil

      not route_query_matches?(route_query, query_params) ->
        nil

      mode == :exact and (current_path in candidates or normalized_path in candidates) ->
        %{page_id: page_id, page_params: exact_route_page_params(primary_path), route_path: primary_path}

      mode == :pattern ->
        Enum.find_value(candidates, fn candidate ->
          match_route_pattern(candidate, current_path, normalized_path, page_id, primary_path)
        end)

      true ->
        nil
    end
  end

  def primary_route_path("", full_path), do: normalize_route_lookup_path(full_path)
  def primary_route_path(route_path, full_path) do
    case normalize_route_lookup_path(route_path) do
      "" -> normalize_route_lookup_path(full_path)
      normalized -> normalized
    end
  end

  defp exact_route_page_params(path) do
    normalized = normalize_route_lookup_path(path)

    cond do
      normalized == "" ->
        %{}

      String.ends_with?(normalized, "/new") ->
        %{"id" => "new"}

      true ->
        %{}
    end
  end

  defp match_route_pattern(pattern, current_path, normalized_path, page_id, primary_path) do
    Enum.find_value([current_path, normalized_path], fn candidate_path ->
      pattern_segments = split_route_segments(pattern)
      current_segments = split_route_segments(candidate_path)

      if length(pattern_segments) != length(current_segments) do
        nil
      else
        Enum.zip(pattern_segments, current_segments)
        |> Enum.reduce_while(%{}, fn
          {pattern_segment, current_segment}, acc when pattern_segment == current_segment ->
            {:cont, acc}

          {":" <> param, current_segment}, acc when param != "" and current_segment != "" ->
            {:cont, Map.put(acc, param, current_segment)}

          _, _acc ->
            {:halt, nil}
        end)
        |> case do
          %{} = page_params -> %{page_id: page_id, page_params: page_params, route_path: primary_path}
          _ -> nil
        end
      end
    end)
  end

  defp normalize_route_lookup_path(path) when is_binary(path) do
    normalized = normalize_string(path)
    prefix = host_prefix()
    normalized = normalized |> String.split("?", parts: 2) |> hd()

    cond do
      normalized == "" ->
        ""

      prefix != "" and String.starts_with?(normalized, prefix <> "/") ->
        String.trim_leading(normalized, prefix)

      normalized == prefix ->
        "/"

      String.starts_with?(normalized, "/") ->
        normalized

      true ->
        "/" <> normalized
    end
  end

  defp normalize_route_lookup_path(_path), do: ""

  defp route_query_matches?("", _query_params), do: true

  defp route_query_matches?(route_query, query_params) when is_map(query_params) do
    expected = split_query_string(route_query)

    Enum.all?(expected, fn {key, value} ->
      normalize_string(map_get(query_params, key)) == value
    end)
  end

  defp route_query_matches?(_route_query, _query_params), do: false

  defp split_query_string(query) when is_binary(query) do
    query
    |> normalize_string()
    |> String.trim_leading("?")
    |> String.split("&", trim: true)
    |> Enum.reduce(%{}, fn part, acc ->
      case String.split(part, "=", parts: 2) do
        [key, value] -> Map.put(acc, normalize_string(key), normalize_string(value))
        [key] -> Map.put(acc, normalize_string(key), "")
      end
    end)
  end

  defp split_query_string(_query), do: %{}

  defp split_route_segments(path) when is_binary(path) do
    path
    |> String.trim()
    |> String.trim_leading("/")
    |> String.split("/", trim: true)
  end

  defp page_template(page_id, page) do
    candidates =
      page
      |> template_candidates(page_id)
      |> Enum.uniq()

    case Enum.find(candidates, &File.exists?/1) do
      nil ->
        {:error, :page_host_template_not_found}

      path ->
        {:ok, path, File.read!(path)}
    end
  end

  defp template_candidates(page, page_id) do
    dsl_file = page |> map_get("dsl_file") |> normalize_string()
    behavior_file = page |> map_get("behavior_file") |> normalize_string()
    domain_snake = page |> map_get("domain_snake") |> normalize_string()
    entity_snake = page |> map_get("entity_snake") |> normalize_string()
    page_kind = page |> map_get("page_kind") |> normalize_string()
    route_path = page |> map_get("route_path") |> normalize_string()
    normalized_page_id = normalize_string(page_id)

    # dsl_file 最后调用 → [new | existing] 排在列表最前面 → 最高优先级 (#1987)
    relative_candidates =
      []
      |> maybe_add_page_id_candidates(normalized_page_id)
      |> maybe_add_route_candidates(route_path)
      |> maybe_add_entity_candidates(domain_snake, entity_snake, page_kind)
      |> maybe_add_behavior_candidates(behavior_file)
      |> maybe_add_dsl_candidates(dsl_file)

    absolute_candidates =
      Enum.map(relative_candidates, &Path.join(pages_dir(), &1))

    absolute_candidates ++ recursive_basename_candidates(normalized_page_id)
  end

  defp maybe_add_dsl_candidates(candidates, ""), do: candidates

  defp maybe_add_dsl_candidates(candidates, dsl_file) do
    [
      String.replace_suffix(dsl_file, ".dsl", ".expanded.generated.heex"),
      String.replace_suffix(dsl_file, ".dsl", ".generated.heex"),
      String.replace_suffix(dsl_file, ".dsl", ".heex")
      | candidates
    ]
  end

  defp maybe_add_behavior_candidates(candidates, ""), do: candidates

  defp maybe_add_behavior_candidates(candidates, behavior_file) do
    base = String.replace_suffix(behavior_file, ".behavior.v1.json", "")
    ["#{base}.expanded.generated.heex", "#{base}.generated.heex", "#{base}.heex" | candidates]
  end

  defp maybe_add_entity_candidates(candidates, "", _entity_snake, _page_kind), do: candidates
  defp maybe_add_entity_candidates(candidates, _domain_snake, "", _page_kind), do: candidates
  defp maybe_add_entity_candidates(candidates, _domain_snake, _entity_snake, ""), do: candidates

  defp maybe_add_entity_candidates(candidates, domain_snake, entity_snake, page_kind) do
    base = Path.join(domain_snake, "#{entity_snake}_#{page_kind}")
    ["#{base}.expanded.generated.heex", "#{base}.generated.heex", "#{base}.heex" | candidates]
  end

  defp maybe_add_page_id_candidates(candidates, ""), do: candidates

  defp maybe_add_page_id_candidates(candidates, page_id) do
    ["#{page_id}.expanded.generated.heex", "#{page_id}.generated.heex", "#{page_id}.heex" | candidates]
  end

  defp maybe_add_route_candidates(candidates, ""), do: candidates

  defp maybe_add_route_candidates(candidates, route_path) do
    segments =
      route_path
      |> String.trim()
      |> String.trim_leading("/")
      |> String.split("/", trim: true)

    case segments do
      [] ->
        candidates

      [single] ->
        [
          "#{single}.expanded.generated.heex",
          "#{single}.generated.heex",
          "#{single}.heex"
          | candidates
        ]

      _ ->
        relative = Path.join(segments)

        [
          "#{relative}.expanded.generated.heex",
          "#{relative}.generated.heex",
          "#{relative}.heex"
          | candidates
        ]
    end
  end

  defp recursive_basename_candidates(""), do: []

  defp recursive_basename_candidates(page_id) do
    pages_dir()
    |> Path.join("**/*.heex")
    |> Path.wildcard()
    |> Enum.filter(fn path ->
      filename = Path.basename(path)

      filename == "#{page_id}.expanded.generated.heex" or
        filename == "#{page_id}.generated.heex" or
        filename == "#{page_id}.heex"
    end)
    |> Enum.sort_by(fn path ->
      path
      |> Path.relative_to(pages_dir())
      |> Path.split()
      |> length()
    end, :desc)
  end

  # custom 页面没有 api_map 时，跳过 GraphQL dispatch，用静态数据加载
  defp load_page_data(path, page_id, page, params, :graphql, backend) do
    api_map = normalize_map(map_get(page, "api_map"))

    if api_map == %{} do
      load_page_data(path, page_id, page, params, :static, backend)
    else
      load_page_data_graphql(path, page_id, page, params, backend)
    end
  end

  defp load_page_data(path, page_id, _page, _params, _runtime_mode, _backend) do
    status_defaults = load_status_defaults(path)

    {:ok,
     @default_assigns
     |> Map.merge(status_defaults)
     |> Map.merge(load_mock_data(path))
     |> maybe_put_page_title(page_id, status_defaults)}
  end

  defp load_page_data_graphql(path, page_id, page, params, backend) do
    status_defaults = load_status_defaults(path)
    page_contract = load_behavior_contract(path)
    selection = page_selection(path, status_defaults)

    seed =
      @default_assigns
      |> Map.merge(status_defaults)
      |> maybe_put_page_title(page_id, status_defaults)
      |> Map.put(:selection, selection)
      |> Map.put(:_page_contract, page_contract)
      |> maybe_inject_default_tenant()
      |> maybe_inject_param_tenant(params)

    # new 模式（创建新记录）：跳过 backend load，初始化空 entity assign + editing 状态
    if Map.get(params, "id") == "new" do
      entity_snake = page |> map_get("entity_snake") |> normalize_string()
      new_seed = seed
        |> Map.put(:editing, true)
        |> Map.put(:create_mode, true)
      new_seed = if entity_snake != "" do
        Map.put_new(new_seed, String.to_atom(entity_snake), %{})
      else
        new_seed
      end
      {:ok, new_seed |> apply_load_assigns()}
    else
      entity_snake = page |> map_get("entity_snake") |> normalize_string()
      case dispatch(backend, page_id, @load_event, params, seed) do
        {:ok, %{dto: dto, status: status, effects: effects}} ->
          result = seed
           |> merge_backend_payload(dto, status)
           |> apply_load_assigns()
           |> maybe_put_flash_from_effects(effects)
          # entity assign 别名：HEEx 的 contract pipeline 用 entity_snake 做 assign key
          result = if entity_snake != "" do
            record = Map.get(result, :record, %{})
            Map.put_new(result, String.to_atom(entity_snake), record)
          else
            result
          end
          {:ok, result}

        {:error, reason} ->
          {:error, {:page_host_load_failed, reason}}

        other ->
          {:error, {:page_host_load_failed, other}}
      end
    end
  end

  defp maybe_put_page_title(page_data, page_id, status_defaults) do
    if normalize_string(map_get(status_defaults, "page_title")) != "" do
      page_data
    else
      Map.put(page_data, :page_title, page_id)
    end
  end

  defp maybe_inject_default_tenant(seed) do
    case RuntimeConfig.default_tenant_id() do
      nil -> seed
      tenant_id -> Map.put_new(seed, "tenant_id", tenant_id)
    end
  end

  # URL params 中的 tenant_id 优先级高于配置默认值
  defp maybe_inject_param_tenant(seed, params) do
    case normalize_string(map_get(normalize_map(params), "tenant_id")) do
      "" -> seed
      tenant_id -> Map.put(seed, "tenant_id", tenant_id)
    end
  end

  defp apply_load_assigns(page_data) do
    load_assigns =
      page_data
      |> Map.get(:_page_contract, %{})
      |> normalize_map()
      |> map_get("backend")
      |> map_get("load")
      |> map_get("assigns")
      |> normalize_map()

    Enum.reduce(load_assigns, page_data, fn {key, spec}, acc ->
      case resolve_load_assign(acc, spec) do
        {:ok, value} ->
          assign_key = String.to_atom(key)
          normalized_value = deep_generated_atomize_keys(value)

          updated_value =
            case {Map.get(acc, assign_key), normalized_value} do
              {existing, value} when is_map(existing) and is_map(value) ->
                deep_merge(existing, value)

              {_existing, value} ->
                value
            end

          if is_nil(updated_value) do
            acc
          else
            Map.put(acc, assign_key, updated_value)
          end

        :error ->
          acc
      end
    end)
  end

  defp resolve_load_assign(page_data, spec) when is_binary(spec) do
    case get_by_path(page_data, spec) do
      nil -> :error
      value -> {:ok, value}
    end
  end

  defp resolve_load_assign(page_data, spec) when is_map(spec) do
    normalized_spec = normalize_map(spec)

    if Map.has_key?(normalized_spec, "value") do
      {:ok, map_get(normalized_spec, "value")}
    else
      source =
        normalized_spec
        |> map_get("from")
        |> normalize_string()

      transform =
        normalized_spec
        |> map_get("transform")
        |> normalize_string()

      case get_by_path(page_data, source) do
        nil ->
          if transform == "" do
            :error
          else
            {:ok, apply_load_transform(nil, transform)}
          end

        value ->
          {:ok, apply_load_transform(value, transform)}
      end
    end
  end

  defp resolve_load_assign(_page_data, _spec), do: :error

  defp apply_load_transform(value, ""), do: value
  defp apply_load_transform(value, "group_requirements_by_shift_type")
       when is_list(value) do
    value
    |> Enum.reduce(%{}, fn requirement, acc ->
      requirement_map = normalize_map(requirement)
      shift_type = normalize_map(map_get(requirement_map, "shift_type"))
      shift_name = normalize_string(map_get(shift_type, "name"))
      shift_id = normalize_string(map_get(shift_type, "id"))

      if shift_name == "" do
        acc
      else
        existing =
          Map.get(acc, shift_id, %{"id" => shift_id, "name" => shift_name, "requirements" => []})

        normalized_requirement =
          %{}
          |> Map.put("id", normalize_string(map_get(requirement_map, "id")))
          |> Map.put("requirement_date", normalize_string(map_get(requirement_map, "requirement_date")))
          |> Map.put("min_headcount", map_get(requirement_map, "min_headcount"))
          |> Map.put("target_headcount", map_get(requirement_map, "target_headcount"))
          |> Map.put("role_code", normalize_string(map_get(requirement_map, "role_code")))
          |> Map.put("role_name", normalize_string(map_get(requirement_map, "role_name")))

        Map.put(
          acc,
          shift_id,
          Map.update!(existing, "requirements", &(&1 ++ [normalized_requirement]))
        )
      end
    end)
    |> Map.values()
  end

  defp apply_load_transform(value, "normalize_list"), do: normalize_list(value)

  defp apply_load_transform(value, "date_range_label") when is_map(value) do
    start_date = value |> map_get("start_date") |> normalize_string()
    end_date = value |> map_get("end_date") |> normalize_string()

    cond do
      start_date != "" and end_date != "" -> "#{start_date} ~ #{end_date}"
      start_date != "" -> start_date
      end_date != "" -> end_date
      true -> ""
    end
  end

  defp apply_load_transform(value, _transform), do: value

  defp get_by_path(data, path) when is_binary(path) do
    path
    |> String.trim_leading("$")
    |> String.split(".", trim: true)
    |> Enum.reduce_while(data, fn segment, acc ->
      case map_get(acc, segment) do
        nil -> {:halt, nil}
        value -> {:cont, value}
      end
    end)
  end

  defp get_by_path(_data, _path), do: nil

  defp page_selection(path, status_defaults) do
    explicit_selection =
      path
      |> load_behavior_contract()
      |> map_get("backend")
      |> map_get("load")
      |> map_get("selection")
      |> normalize_string()

    cond do
      explicit_selection != "" ->
        explicit_selection

      true ->
        build_selection_from_defaults(status_defaults)
    end
  end

  defp build_selection_from_defaults(defaults) do
    rows = map_get(defaults, "rows")
    record = map_get(defaults, "record")
    form = map_get(defaults, "form")

    # 检测 defaults 中任意 list 类型的值（如 records），作为 rows 的 fallback
    any_list =
      Enum.find_value(defaults, nil, fn
        {_key, value} when is_list(value) and value != [] -> value
        _ -> nil
      end)

    sample =
      cond do
        is_list(rows) and match?([first | _] when is_map(first), rows) ->
          List.first(rows)

        is_list(any_list) and match?([first | _] when is_map(first), any_list) ->
          List.first(any_list)

        is_map(record) and map_size(record) > 0 ->
          record

        is_map(form) and map_size(form) > 0 ->
          form

        true ->
          %{}
      end

    fields = extract_selection_fields(sample)

    case fields do
      "" -> "id"
      value -> "id " <> value
    end
  end

  defp extract_selection_fields(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.reject(&(&1 in [:id, :__struct__, :__meta__]))
    |> Enum.map(fn key ->
      value = Map.get(map, key)
      key_str = to_string(key)

      cond do
        is_map(value) and not Map.has_key?(value, :__struct__) and map_size(value) > 0 ->
          nested = extract_selection_fields(value)
          if nested == "", do: key_str, else: key_str <> " { " <> nested <> " }"

        is_list(value) ->
          case value do
            [first | _] when is_map(first) ->
              nested = extract_selection_fields(first)
              if nested == "", do: key_str, else: key_str <> " { " <> nested <> " }"

            _ ->
              key_str
          end

        true ->
          key_str
      end
    end)
    |> Enum.join(" ")
  end

  defp extract_selection_fields(_), do: ""

  defp load_behavior_contract(heex_path) do
    heex_path
    |> behavior_path_candidates()
    |> Enum.reduce(%{}, fn path, acc ->
      case read_behavior_contract(path) do
        %{} = data when map_size(data) > 0 -> deep_merge(acc, data)
        _ -> acc
      end
    end)
  end

  defp read_behavior_contract(path) when is_binary(path) do
    if File.exists?(path) do
      case File.read(path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, %{} = data} -> data
            _ -> %{}
          end

        _ ->
          %{}
      end
    else
      %{}
    end
  end

  defp behavior_path_candidates(heex_path) do
    page_id =
      heex_path
      |> Path.basename()
      |> String.replace_suffix(".expanded.generated.heex", "")
      |> String.replace_suffix(".generated.heex", "")
      |> String.replace_suffix(".heex", "")

    app_root = File.cwd!()

    [
      String.replace_suffix(heex_path, ".expanded.generated.heex", ".expanded.behavior.v1.json"),
      String.replace_suffix(heex_path, ".generated.heex", ".behavior.v1.json"),
      String.replace_suffix(heex_path, ".heex", ".behavior.v1.json"),
      Path.join(app_root, "pages/scheduling/admin/#{page_id}.behavior.v1.json")
    ]
    |> Enum.uniq()
  end

  defp load_mock_data(heex_path) do
    heex_path
    |> mock_path_candidates()
    |> Enum.find_value(%{}, &read_mock_payload/1)
  end

  defp load_status_defaults(heex_path) do
    # #1748: expanded 模板也要查找对应的 status.schema.v1.json
    status_candidates = [
      String.replace_suffix(heex_path, ".expanded.generated.heex", ".expanded.status.schema.v1.json"),
      String.replace_suffix(heex_path, ".generated.heex", ".status.schema.v1.json"),
      String.replace_suffix(heex_path, ".heex", ".status.schema.v1.json")
    ]

    status_path = Enum.find(status_candidates, &File.exists?/1)

    if status_path do
      case File.read(status_path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, %{"defaults" => defaults}} when is_map(defaults) ->
              deep_generated_atomize_keys(defaults)

            {:ok, %{"state_schema" => %{"defaults" => defaults}}} when is_map(defaults) ->
              deep_generated_atomize_keys(defaults)

            _ ->
              %{}
          end

        _ ->
          %{}
      end
    else
      %{}
    end
  end

  defp manifest_pages do
    routes_by_page =
      RuntimeConfig.frontend_route_map()
      |> normalize_list()
      |> Enum.reduce(%{}, fn route, acc ->
        page_id = route |> map_get("page_id") |> normalize_string()
        route_query = route |> map_get("query") |> normalize_string()
        route_path =
          primary_route_path(
            route |> map_get("path") |> normalize_string(),
            route |> map_get("full_path") |> normalize_string()
          )

        cond do
          page_id == "" or route_path == "" -> acc
          Map.has_key?(acc, page_id) -> acc
          true -> Map.put(acc, page_id, %{"path" => route_path, "query" => route_query})
        end
      end)

    RuntimeConfig.frontend_pages()
    |> normalize_list()
    |> Enum.map(fn page ->
      page_id = page |> map_get("page_id") |> normalize_string()
      route_info = Map.get(routes_by_page, page_id, %{"path" => "/" <> page_id, "query" => ""})
      route_path = route_info |> map_get("path") |> normalize_string()
      route_query = route_info |> map_get("query") |> normalize_string()
      display_name =
        page
        |> map_get("display_name")
        |> normalize_string()
        |> case do
          "" -> page_id
          value -> value
        end

      route_target =
        case route_query do
          "" -> route_path
          value -> route_path <> "?" <> value
        end

      %{name: display_name, file: page |> map_get("page_type") |> normalize_string(), route: route_path, query: route_query, host_route: normalize_host_target(route_target, page_id)}
    end)
    |> Enum.reject(&(&1.name == ""))
    |> Enum.sort_by(& &1.name)
  end

  defp list_pages_from_directory do
    pages_dir()
    |> Path.join("**/*.heex")
    |> Path.wildcard()
      |> Enum.map(fn path ->
        filename = Path.basename(path)

        page_id =
          filename
          |> String.replace_suffix(".expanded.generated.heex", "")
          |> String.replace_suffix(".generated.heex", "")
          |> String.replace_suffix(".heex", "")

      %{name: page_id, file: Path.relative_to(path, pages_dir()), route: "/" <> page_id, host_route: normalize_host_target(page_id, page_id)}
      end)
    |> Enum.reject(&(&1.name == ""))
    |> Enum.sort_by(& &1.name)
    |> Enum.uniq_by(& &1.name)
  end

  defp mock_path_candidates(heex_path) do
    [
      String.replace_suffix(heex_path, ".expanded.generated.heex", ".expanded.mock.json"),
      String.replace_suffix(heex_path, ".generated.heex", ".mock.json"),
      String.replace_suffix(heex_path, ".heex", ".mock.json")
    ]
    |> Enum.uniq()
  end

  defp read_mock_payload(path) do
    if File.exists?(path) do
      case File.read(path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, %{} = payload} -> deep_generated_atomize_keys(payload)
            _ -> nil
          end

        _ ->
          nil
      end
    else
      nil
    end
  end

  defp deep_generated_atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, val}, acc ->
      atom_key = if is_binary(key), do: String.to_atom(key), else: key
      Map.put(acc, atom_key, deep_generated_atomize_keys(val))
    end)
  end

  defp deep_generated_atomize_keys(value) when is_list(value),
    do: Enum.map(value, &deep_generated_atomize_keys/1)

  defp deep_generated_atomize_keys(value), do: value

  defp deep_existing_atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, val}, acc ->
      normalized_key = normalize_string(key)

      atom_key =
        try do
          String.to_existing_atom(normalized_key)
        rescue
          ArgumentError -> normalized_key
        end

      Map.put(acc, atom_key, deep_existing_atomize_keys(val))
    end)
  end

  defp deep_existing_atomize_keys(value) when is_list(value),
    do: Enum.map(value, &deep_existing_atomize_keys/1)

  defp deep_existing_atomize_keys(value), do: value

  defp deep_merge(left, right) when is_map(left) and is_map(right) do
    Map.merge(left, right, fn _key, left_value, right_value ->
      deep_merge(left_value, right_value)
    end)
  end

  # #1646: 后端返回 nil 时保留 status_defaults 中的默认结构，
  # 避免嵌套关联（如 last_solver_run）被 nil 覆盖后 dot-access 崩溃
  defp deep_merge(left, nil) when is_map(left), do: left

  defp deep_merge(_left, right), do: right
end
