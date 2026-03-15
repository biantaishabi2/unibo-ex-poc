defmodule HospitalSchedulingWeb.Live.PageHostRuntime do
  @moduledoc """
  页面宿主运行时适配层。

  负责统一处理：
  - `mock/graphql` runtime 切换
  - 页面目录与 `frontend_manifest.v1.json` 消费
  - backend load / dispatch
  - mock/status 默认值装载
  """

  alias HospitalSchedulingWeb.Graphql.RuntimeConfig
  alias HospitalSchedulingWeb.Graphql.StitchBackend

  @load_event "__load__"
  @default_pages_dir Path.join(
                       :code.priv_dir(:hospital_scheduling),
                       "static/scheduling_pages/scheduling"
                     )

  @default_assigns %{
    page_title: "",
    record: %{
      title: "",
      state: "",
      generation_mode: "",
      department: %{name: ""},
      start_date: "",
      end_date: "",
      current_version: %{version_no: ""},
      last_solver_run: %{status: ""},
      schedule_versions: [],
      solver_runs: []
    },
    rows: [],
    rows_empty: true,
    period: %{title: "", state: "", start_date: "", end_date: ""},
    run: %{
      status: "",
      engine_type: "",
      hard_violation_count: "",
      warning_count: "",
      output_snapshot: %{
        summary: %{
          assignment_count: "",
          covered_requirement_count: ""
        }
      }
    },
    version: %{version_no: "", origin_type: ""},
    violations: [],
    violations_empty: true,
    has_hard_violations: false,
    has_warnings: false,
    hard_violation_count: 0,
    warning_count: 0,
    change_count: 0,
    affected_employee_count: 0,
    coverage_rate: 0,
    changes: [],
    no_changes: true,
    employees: [],
    live_violations: [],
    no_violations: true,
    manual_change_count: 0,
    current_week_label: "",
    shift_types: [],
    editing: false,
    filter: %{},
    flash_preview: %{}
  }

  def default_assigns, do: @default_assigns

  def load_page(page, params, runtime_mode, backend) when is_binary(page) do
    case page_template(page) do
      {:ok, path, content} ->
        page_data = load_page_data(path, page, params, runtime_mode, backend)
        {:ok, %{path: path, content: content, page_data: page_data}}

      {:error, _reason} = error ->
        error
    end
  end

  def load_page(_page, _params, _runtime_mode, _backend), do: {:error, "页面不存在"}

  def dispatch(backend, page, event, params, state)
      when is_atom(backend) and is_binary(page) and is_binary(event) and is_map(params) and
             is_map(state) do
    if function_exported?(backend, :dispatch, 3) do
      backend.dispatch(
        event,
        %{"__page_id" => page} |> Map.merge(stringify_map(params)),
        stringify_map(state)
      )
    else
      {:error, :page_backend_not_available}
    end
  end

  def dispatch(_backend, _page, _event, _params, _state),
    do: {:error, :page_backend_not_available}

  def merge_backend_payload(page_data, dto, status) do
    page_data
    |> Map.merge(deep_atomize_keys(normalize_map(dto)))
    |> Map.merge(deep_atomize_keys(normalize_map(status)))
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
      |> deep_atomize_keys()
    end)
  end

  def normalize_effects(_effects), do: []

  def runtime_mode do
    case Application.get_env(:hospital_scheduling, :scheduling_page_runtime, :mock) do
      :graphql -> :graphql
      "graphql" -> :graphql
      _ -> :mock
    end
  end

  def page_backend do
    Application.get_env(:hospital_scheduling, :scheduling_page_backend, StitchBackend)
  end

  def pages_dir do
    Application.get_env(:hospital_scheduling, :scheduling_pages_dir, @default_pages_dir)
  end

  def list_pages do
    case manifest_pages() do
      [] -> list_pages_from_directory()
      pages -> pages
    end
  end

  def normalize_map(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} -> {key, value}
    end)
  end

  def normalize_map(_map), do: %{}

  def deep_atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, val}, acc ->
      atom_key = if is_binary(key), do: String.to_atom(key), else: key
      Map.put(acc, atom_key, deep_atomize_keys(val))
    end)
  end

  def deep_atomize_keys(value) when is_list(value), do: Enum.map(value, &deep_atomize_keys/1)
  def deep_atomize_keys(value), do: value

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

  defp page_template(page) do
    candidates = [
      Path.join(pages_dir(), "#{page}.expanded.generated.heex"),
      Path.join(pages_dir(), "#{page}.generated.heex"),
      Path.join(pages_dir(), "#{page}.heex")
    ]

    case Enum.find(candidates, &File.exists?/1) do
      nil ->
        {:error, "页面不存在: #{page}"}

      path ->
        {:ok, path, File.read!(path)}
    end
  end

  defp load_page_data(path, page, params, :graphql, backend) do
    defaults =
      @default_assigns
      |> Map.merge(load_status_defaults(path))
      |> Map.put(:page_title, page)

    case dispatch(backend, page, @load_event, params, defaults) do
      {:ok, %{dto: dto, status: status, effects: effects}} ->
        defaults
        |> merge_backend_payload(dto, status)
        |> maybe_put_flash_from_effects(effects)

      _ ->
        defaults
    end
  end

  defp load_page_data(path, page, _params, _runtime_mode, _backend) do
    @default_assigns
    |> Map.merge(load_status_defaults(path))
    |> Map.put(:page_title, page)
    |> Map.merge(load_mock_data(path))
  end

  defp load_mock_data(heex_path) do
    mock_path = String.replace_suffix(heex_path, ".heex", ".mock.json")

    if File.exists?(mock_path) do
      case File.read(mock_path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, data} when is_map(data) -> deep_atomize_keys(data)
            _ -> %{}
          end

        _ ->
          %{}
      end
    else
      %{}
    end
  end

  defp load_status_defaults(heex_path) do
    status_path = String.replace_suffix(heex_path, ".generated.heex", ".status.schema.v1.json")

    if File.exists?(status_path) do
      case File.read(status_path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, %{"defaults" => defaults}} when is_map(defaults) ->
              deep_atomize_keys(defaults)

            {:ok, %{"state_schema" => %{"defaults" => defaults}}} when is_map(defaults) ->
              deep_atomize_keys(defaults)

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
    frontend_manifest =
      RuntimeConfig.frontend_manifest()
      |> case do
        %{} = manifest when map_size(manifest) > 0 -> manifest
        _ -> load_frontend_manifest_from_file()
      end

    routes_by_page =
      frontend_manifest
      |> map_get("route_map")
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

    frontend_manifest
    |> map_get("pages")
    |> normalize_list()
    |> Enum.map(fn page ->
      page_id = page |> map_get("page_id") |> normalize_string()

      %{
        name: page_id,
        file: page |> map_get("page_type") |> normalize_string(),
        route: Map.get(routes_by_page, page_id, "/scheduling/#{page_id}")
      }
    end)
    |> Enum.reject(&(&1.name == ""))
    |> Enum.sort_by(& &1.name)
  end

  defp load_frontend_manifest_from_file do
    manifest_path = RuntimeConfig.frontend_manifest_path()

    if File.exists?(manifest_path) do
      case File.read(manifest_path) do
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

  defp list_pages_from_directory do
    if File.dir?(pages_dir()) do
      pages_dir()
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".heex"))
      |> Enum.map(fn file ->
        name =
          file
          |> String.replace_suffix(".expanded.generated.heex", "")
          |> String.replace_suffix(".generated.heex", "")
          |> String.replace_suffix(".heex", "")

        %{name: name, file: file, route: "/scheduling/#{name}"}
      end)
      |> Enum.sort_by(& &1.name)
      |> Enum.uniq_by(& &1.name)
    else
      []
    end
  end
end
