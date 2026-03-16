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
  @page_titles %{
    "shift_type_list" => "班次列表",
    "shift_type_detail" => "班次详情",
    "scheduling_period_list" => "排班周期列表",
    "scheduling_period_detail" => "排班周期详情",
    "scheduling_constraint_list" => "排班约束列表",
    "scheduling_constraint_detail" => "排班约束详情",
    "requirement_matrix" => "需求矩阵",
    "solver_result" => "求解结果",
    "calendar_adjustment" => "日历调班",
    "publish_preview" => "发布预览"
  }

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
        case load_page_data(path, page, params, runtime_mode, backend) do
          {:ok, page_data} ->
            {:ok, %{path: path, content: content, page_data: page_data}}

          {:error, _reason} = error ->
            error
        end

      {:error, _reason} = error ->
        error
    end
  end

  def load_page(_page, _params, _runtime_mode, _backend), do: {:error, "页面不存在"}

  def dispatch(backend, page, event, params, state)
      when is_atom(backend) and is_binary(page) and is_binary(event) and is_map(params) and
             is_map(state) do
    case Code.ensure_loaded(backend) do
      {:module, _module} ->
        if function_exported?(backend, :dispatch, 3) do
          backend.dispatch(
            event,
            %{"__page_id" => page} |> Map.merge(stringify_map(params)),
            stringify_map(state)
          )
        else
          {:error, :page_backend_not_available}
        end

      _ ->
        {:error, :page_backend_not_available}
    end
  end

  def dispatch(_backend, _page, _event, _params, _state),
    do: {:error, :page_backend_not_available}

  def merge_backend_payload(page_data, dto, status) do
    page_data
    |> deep_merge(deep_atomize_keys(normalize_map(dto)))
    |> deep_merge(deep_atomize_keys(normalize_map(status)))
    |> apply_load_assigns()
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

  def page_contract(page) when is_binary(page) do
    case page_template(page) do
      {:ok, path, _content} -> load_behavior_contract(path)
      _ -> %{}
    end
  end

  def page_contract(_page), do: %{}

  def normalize_page_params(page, params) when is_binary(page) and is_map(params) do
    params = stringify_map(params)
    route_id = map_get(params, "id") |> normalize_string()

    accepted =
      page
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

  def normalize_page_params(_page, params) when is_map(params), do: stringify_map(params)
  def normalize_page_params(_page, _params), do: %{}

  defp maybe_put_route_id(params, ""), do: params
  defp maybe_put_route_id(params, id), do: Map.put(params, "id", id)
  defp maybe_restore_original_params(%{} = normalized, %{} = original) when map_size(normalized) == 0 and map_size(original) > 0, do: original
  defp maybe_restore_original_params(normalized, _original), do: normalized

  def supports_reload?(page) when is_binary(page) do
    messages =
      page
      |> page_contract()
      |> map_get("backend")
      |> map_get("info")
      |> map_get("reload_messages")
      |> normalize_string_list()

    messages == [] or "page_host_reload" in messages
  end

  def supports_reload?(_page), do: false

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

  def normalize_string_list(values) when is_list(values) do
    values
    |> Enum.map(&normalize_string/1)
    |> Enum.reject(&(&1 == ""))
  end

  def normalize_string_list(_values), do: []

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
    status_defaults = load_status_defaults(path)
    selection = page_selection(page, path, status_defaults)

    defaults =
      @default_assigns
      |> Map.merge(status_defaults)
      |> Map.put(:page_title, page)
      |> Map.put(:selection, selection)
      |> Map.put(:_page_contract, page_contract(page))

    case dispatch(backend, page, @load_event, params, defaults) do
      {:ok, %{dto: dto, status: status, effects: effects}} ->
        {:ok,
         defaults
         |> merge_backend_payload(dto, status)
         |> maybe_put_flash_from_effects(effects)}

      {:error, reason} ->
        {:error, "页面加载失败: #{inspect(reason)}"}

      other ->
        {:error, "页面加载失败: #{inspect(other)}"}
    end
  end

  defp load_page_data(path, page, _params, _runtime_mode, _backend) do
    {:ok,
     @default_assigns
     |> Map.merge(load_status_defaults(path))
     |> Map.put(:page_title, page)
     |> Map.merge(load_mock_data(path))}
  end

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

  defp build_selection_from_defaults(defaults) do
    sample =
      cond do
        is_list(defaults[:rows]) and match?([first | _] when is_map(first), defaults[:rows]) ->
          List.first(defaults[:rows])

        is_map(defaults[:record]) and map_size(defaults[:record]) > 0 ->
          defaults[:record]

        is_map(defaults[:form]) and map_size(defaults[:form]) > 0 ->
          defaults[:form]

        true ->
          %{}
      end

    case extract_selection_fields(sample) do
      "" -> "id"
      fields -> "id " <> fields
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
          normalized_value = deep_atomize_keys(value)

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
          Map.get(acc, shift_id, %{
            "id" => shift_id,
            "name" => shift_name,
            "requirements" => []
          })

        normalized_requirement =
          %{
            "id" => normalize_string(map_get(requirement_map, "id")),
            "requirement_date" => normalize_string(map_get(requirement_map, "requirement_date")),
            "min_headcount" => map_get(requirement_map, "min_headcount"),
            "target_headcount" => map_get(requirement_map, "target_headcount"),
            "role_code" => normalize_string(map_get(requirement_map, "role_code")),
            "role_name" => normalize_string(map_get(requirement_map, "role_name"))
          }

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

  defp apply_load_transform(nil, "normalize_solver_run") do
    %{
      "status" => "",
      "engine_type" => "",
      "hard_violation_count" => "",
      "warning_count" => "",
      "output_snapshot" => %{
        "summary" => %{
          "assignment_count" => "",
          "covered_requirement_count" => ""
        }
      }
    }
  end

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

  defp apply_load_transform(value, "normalize_solver_run") when is_map(value) do
    value = normalize_map(value)

    output_snapshot =
      case map_get(value, "output_snapshot") do
        json when is_binary(json) ->
          case Jason.decode(json) do
            {:ok, decoded} when is_map(decoded) -> decoded
            _ -> %{}
          end

        snapshot when is_map(snapshot) ->
          snapshot

        _ ->
          %{}
      end

    summary = normalize_map(map_get(normalize_map(output_snapshot), "summary"))

    %{
      "status" => normalize_string(map_get(value, "status")),
      "engine_type" => normalize_string(map_get(value, "engine_type")),
      "hard_violation_count" => map_get(value, "hard_violation_count") || "",
      "warning_count" => map_get(value, "warning_count") || "",
      "output_snapshot" => %{
        "summary" => %{
          "assignment_count" => map_get(summary, "assignment_count") || "",
          "covered_requirement_count" => map_get(summary, "covered_requirement_count") || ""
        }
      }
    }
  end

  defp apply_load_transform(value, "positive_count") when is_integer(value), do: value > 0
  defp apply_load_transform(value, "positive_count") when is_float(value), do: value > 0
  defp apply_load_transform(value, "positive_count"), do: value not in [nil, "", 0, 0.0]

  defp apply_load_transform(value, "empty_list") when is_list(value), do: value == []
  defp apply_load_transform(value, "empty_list"), do: value in [nil, ""]

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

  defp page_selection(_page, path, status_defaults) do
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

  defp extract_selection_fields(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.reject(&(&1 in [:id, :__struct__, :__meta__]))
    |> Enum.map(fn key ->
      value = Map.get(map, key)
      key_str = to_string(key)

      cond do
        is_map(value) and map_size(value) > 0 ->
          nested = extract_selection_fields(value)
          if nested == "", do: key_str, else: key_str <> " { " <> nested <> " }"

        is_list(value) ->
          case Enum.find(value, &is_map/1) do
            nil ->
              key_str

            first ->
              nested = extract_selection_fields(first)
              if nested == "", do: key_str, else: key_str <> " { " <> nested <> " }"
          end

        true ->
          key_str
      end
    end)
    |> Enum.join(" ")
  end

  defp extract_selection_fields(_), do: ""

  defp deep_merge(left, right) when is_map(left) and is_map(right) do
    Map.merge(left, right, fn _key, left_value, right_value ->
      deep_merge(left_value, right_value)
    end)
  end

  defp deep_merge(left, nil), do: left
  defp deep_merge(_left, right), do: right

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
      display_name =
        page
        |> map_get("display_name")
        |> normalize_string()
        |> case do
          "" -> Map.get(@page_titles, page_id, page_id)
          value -> value
        end

      %{
        name: display_name,
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
        page_id =
          file
          |> String.replace_suffix(".expanded.generated.heex", "")
          |> String.replace_suffix(".generated.heex", "")
          |> String.replace_suffix(".heex", "")

        %{
          name: Map.get(@page_titles, page_id, page_id),
          file: file,
          route: "/scheduling/#{page_id}"
        }
      end)
      |> Enum.sort_by(& &1.name)
      |> Enum.uniq_by(& &1.name)
    else
      []
    end
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
            {:ok, data} when is_map(data) -> deep_atomize_keys(data)
            _ -> nil
          end

        _ ->
          nil
      end
    end
  end
end
