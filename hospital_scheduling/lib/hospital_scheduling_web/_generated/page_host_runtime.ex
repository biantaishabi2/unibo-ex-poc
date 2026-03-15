defmodule HospitalSchedulingWeb.Generated.PageHostRuntime do
  @moduledoc """
  通用页面宿主运行时（由 UniBO 自动生成）。

  负责：
  - `frontend_manifest.v1.json` / `route_map` 消费
  - `mock/graphql` runtime 切换
  - 页面模板、状态默认值、mock 数据装载
  - backend dispatch 与 effects 归一化
  """

  alias HospitalSchedulingWeb.Graphql.RuntimeConfig

  @load_event "__load__"
  @default_assigns %{page_title: "", flash_preview: %{}}

  def default_assigns, do: @default_assigns

  def load_page(page_id, params, runtime_mode \\ runtime_mode(), backend \\ page_backend())

  def load_page(page_id, params, runtime_mode, backend) when is_binary(page_id) do
    with {:ok, page} <- RuntimeConfig.frontend_page(page_id),
         {:ok, path, content} <- page_template(page_id, page),
         {:ok, page_data} <- load_page_data(path, page_id, params, runtime_mode, backend) do
      {:ok, %{page: page, path: path, content: content, page_data: page_data}}
    end
  end

  def load_page(_page_id, _params, _runtime_mode, _backend),
    do: {:error, :page_host_page_not_found}

  def resolve_host_route(route_segments) when is_list(route_segments) do
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
        resolve_host_route_path(path)
    end
  end

  def resolve_host_route(route_path) when is_binary(route_path) do
    route_path
    |> normalize_string()
    |> case do
      "" -> {:error, :page_host_page_not_found}
      path ->
        if String.starts_with?(path, "/") do
          resolve_host_route_path(path)
        else
          resolve_host_route_path("/" <> path)
        end
    end
  end

  def resolve_host_route(_route_segments), do: {:error, :page_host_page_not_found}

  def dispatch(backend, page_id, event, params, state)
      when is_atom(backend) and is_binary(page_id) and is_binary(event) and is_map(params) and
             is_map(state) do
    if function_exported?(backend, :dispatch, 3) do
      backend.dispatch(
        event,
        %{"__page_id" => page_id} |> Map.merge(stringify_map(params)),
        stringify_map(state)
      )
    else
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

  def list_pages do
    case manifest_pages() do
      [] -> list_pages_from_directory()
      pages -> pages
    end
  end

  def host_path_for_page(page) when is_map(page) do
    page
    |> map_get("route")
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

  defp resolve_host_route_path(path) do
    route_map = RuntimeConfig.frontend_route_map()

    case Enum.find_value(route_map, fn route ->
           match_route(route, path)
         end) do
      %{} = resolved ->
        {:ok, resolved}

      _ ->
        page_id =
          path
          |> String.trim_leading("/")
          |> normalize_string()

        case RuntimeConfig.frontend_page(page_id) do
          {:ok, _page} ->
            {:ok, %{page_id: page_id, page_params: %{}, route_path: path}}

          _ ->
            {:error, :page_host_page_not_found}
        end
    end
  end

  defp match_route(route, current_path) do
    route_path = route |> map_get("path") |> normalize_string()
    page_id = route |> map_get("page_id") |> normalize_string()

    cond do
      route_path == "" or page_id == "" ->
        nil

      route_path == current_path ->
        %{page_id: page_id, page_params: %{}, route_path: route_path}

      true ->
        pattern_segments = split_route_segments(route_path)
        current_segments = split_route_segments(current_path)

        if length(pattern_segments) != length(current_segments) do
          nil
        else
          Enum.zip(pattern_segments, current_segments)
          |> Enum.reduce_while(%{}, fn
            {pattern, current}, acc when pattern == current ->
              {:cont, acc}

            {":" <> param, current}, acc when param != "" and current != "" ->
              {:cont, Map.put(acc, param, current)}

            _, _acc ->
              {:halt, nil}
          end)
          |> case do
            %{} = page_params -> %{page_id: page_id, page_params: page_params, route_path: route_path}
            _ -> nil
          end
        end
    end
  end

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
    normalized_page_id = normalize_string(page_id)

    relative_candidates =
      []
      |> maybe_add_dsl_candidates(dsl_file)
      |> maybe_add_behavior_candidates(behavior_file)
      |> maybe_add_entity_candidates(domain_snake, entity_snake, page_kind)
      |> maybe_add_page_id_candidates(normalized_page_id)

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
  end

  defp load_page_data(path, page_id, params, :graphql, backend) do
    status_defaults = load_status_defaults(path)

    seed =
      @default_assigns
      |> Map.merge(status_defaults)
      |> Map.merge(load_mock_data(path))
      |> maybe_put_page_title(page_id, status_defaults)
      |> Map.put(:selection, build_selection_from_defaults(status_defaults))

    case dispatch(backend, page_id, @load_event, params, seed) do
      {:ok, %{dto: dto, status: status, effects: effects}} ->
        {:ok,
         seed
         |> merge_backend_payload(dto, status)
         |> maybe_put_flash_from_effects(effects)}

      {:error, reason} ->
        {:error, {:page_host_load_failed, reason}}

      other ->
        {:error, {:page_host_load_failed, other}}
    end
  end

  defp load_page_data(path, page_id, _params, _runtime_mode, _backend) do
    status_defaults = load_status_defaults(path)

    {:ok,
     @default_assigns
     |> Map.merge(status_defaults)
     |> Map.merge(load_mock_data(path))
     |> maybe_put_page_title(page_id, status_defaults)}
  end

  defp maybe_put_page_title(page_data, page_id, status_defaults) do
    if normalize_string(map_get(status_defaults, "page_title")) != "" do
      page_data
    else
      Map.put(page_data, :page_title, page_id)
    end
  end

  defp build_selection_from_defaults(defaults) do
    rows = map_get(defaults, "rows")
    record = map_get(defaults, "record")
    form = map_get(defaults, "form")

    sample =
      cond do
        is_list(rows) and match?([first | _] when is_map(first), rows) ->
          List.first(rows)

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

  defp load_mock_data(heex_path) do
    heex_path
    |> mock_path_candidates()
    |> Enum.find_value(%{}, &read_mock_payload/1)
  end

  defp load_status_defaults(heex_path) do
    status_path = String.replace_suffix(heex_path, ".generated.heex", ".status.schema.v1.json")

    if File.exists?(status_path) do
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
        route_path = route |> map_get("path") |> normalize_string()

        cond do
          page_id == "" or route_path == "" -> acc
          Map.has_key?(acc, page_id) -> acc
          true -> Map.put(acc, page_id, route_path)
        end
      end)

    RuntimeConfig.frontend_pages()
    |> normalize_list()
    |> Enum.map(fn page ->
      page_id = page |> map_get("page_id") |> normalize_string()
      route_path = Map.get(routes_by_page, page_id, "/" <> page_id)

      %{name: page_id, file: page |> map_get("page_type") |> normalize_string(), route: route_path, host_route: normalize_host_target(route_path, page_id)}
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

      name =
        filename
        |> String.replace_suffix(".expanded.generated.heex", "")
        |> String.replace_suffix(".generated.heex", "")
        |> String.replace_suffix(".heex", "")

      %{name: name, file: Path.relative_to(path, pages_dir()), route: "/" <> name, host_route: normalize_host_target(name, name)}
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

  defp deep_merge(_left, right), do: right
end
