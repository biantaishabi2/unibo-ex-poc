defmodule HospitalSchedulingWeb.SchedulingLive do
  @moduledoc """
  排班管理页面动态渲染 LiveView。
  从运行时页面目录加载 `.generated.heex`，并按配置切换：

  - `:mock`：读取 `.mock.json`
  - `:graphql`：走 Stitch backend contract
  """
  use Phoenix.LiveView, layout: {HospitalSchedulingWeb.Layouts, :app}

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

  @default_pages_dir Path.join(
                       :code.priv_dir(:hospital_scheduling),
                       "static/scheduling_pages/scheduling"
                     )
  @load_event "__load__"

  @impl true
  def mount(%{"page" => page} = params, _session, socket) do
    socket =
      socket
      |> assign(:runtime_mode, runtime_mode())
      |> assign(:page_backend, page_backend())
      |> assign(:page, page)
      |> assign(:page_params, Map.delete(params, "page"))
      |> assign(:error, nil)
      |> assign(:page_template_content, nil)
      |> assign(:page_source_path, nil)
      |> assign(:page_data, @default_assigns)
      |> assign(:rendered_content, nil)
      |> load_and_render(page, Map.delete(params, "page"))

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    pages = list_pages()

    socket =
      socket
      |> assign(:runtime_mode, runtime_mode())
      |> assign(:page_backend, page_backend())
      |> assign(:page, nil)
      |> assign(:error, nil)
      |> assign(:page_template_content, nil)
      |> assign(:page_source_path, nil)
      |> assign(:page_data, @default_assigns)
      |> assign(:rendered_content, nil)
      |> assign(:pages, pages)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"page" => page} = params, _uri, socket) do
    socket =
      socket
      |> assign(:page, page)
      |> assign(:page_params, Map.delete(params, "page"))
      |> assign(:error, nil)
      |> load_and_render(page, Map.delete(params, "page"))

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :pages, list_pages())}
  end

  @impl true
  def handle_event(_event, _params, %{assigns: %{page: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event(event, params, socket) do
    socket =
      case socket.assigns.runtime_mode do
        :graphql -> dispatch_backend(event, params, socket)
        _ -> socket
      end

    {:noreply, socket}
  end

  defp load_and_render(socket, page, params) do
    candidates = [
      Path.join(pages_dir(), "#{page}.expanded.generated.heex"),
      Path.join(pages_dir(), "#{page}.generated.heex"),
      Path.join(pages_dir(), "#{page}.heex")
    ]

    case Enum.find(candidates, &File.exists?/1) do
      nil ->
        assign(socket, :error, "页面不存在: #{page}")

      file_path ->
        content = File.read!(file_path)

        socket =
          socket
          |> assign(:page_source_path, file_path)
          |> assign(:page_template_content, content)

        data = load_page_data(socket, page, params, file_path)
        render_page(socket, content, data)
    end
  end

  defp load_page_data(socket, page, params, heex_path) do
    status_defaults = load_status_defaults(heex_path)

    defaults =
      @default_assigns
      |> Map.merge(status_defaults)
      |> then(fn d ->
        # status schema 已提供 page_title 时不覆盖，否则用 page_id 兜底
        if Map.get(status_defaults, :page_title, "") != "" do
          d
        else
          Map.put(d, :page_title, page)
        end
      end)

    case socket.assigns.runtime_mode do
      :graphql ->
        # 从 status schema defaults 推导 selection，确保查询返回页面需要的全部字段
        selection = build_selection_from_defaults(defaults)
        state = Map.put(defaults, :selection, selection)

        case call_backend(
               socket.assigns.page_backend,
               @load_event,
               %{"__page_id" => page} |> Map.merge(stringify_map(params)),
               state
             ) do
          {:ok, %{dto: dto, status: status, effects: effects}} ->
            defaults
            |> merge_backend_payload(dto, status)
            |> maybe_put_flash_from_effects(effects)

          _ ->
            defaults
        end

      _ ->
        Map.merge(defaults, load_mock_data(heex_path))
    end
  end

  # 从 status schema defaults 推导 GraphQL selection string
  defp build_selection_from_defaults(defaults) do
    # 从 rows（list 页面）或 record（detail 页面）提取字段名
    sample =
      case defaults do
        %{rows: [first | _]} when is_map(first) -> first
        %{record: record} when is_map(record) and map_size(record) > 0 -> record
        _ -> %{}
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
          if nested == "", do: key_str, else: "#{key_str} { #{nested} }"

        is_list(value) ->
          case value do
            [first | _] when is_map(first) ->
              nested = extract_selection_fields(first)
              if nested == "", do: key_str, else: "#{key_str} { #{nested} }"

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

  defp render_page(socket, content, page_data) do
    try do
      module_name = :"Elixir.SchedulingDynamic.Render#{:erlang.unique_integer([:positive])}"

      module_code = """
      defmodule #{module_name} do
        use Phoenix.Component

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

        def render(assigns) do
          ~H\"\"\"
      #{content}
          \"\"\"
        end
      end
      """

      Code.compile_string(module_code)

      assigns =
        @default_assigns
        |> Map.merge(page_data)
        |> Map.put(:flash, Map.get(socket.assigns, :flash, %{}))
        |> Map.put(:__changed__, nil)

      result = apply(module_name, :render, [assigns])

      :code.purge(module_name)
      :code.delete(module_name)

      socket
      |> assign(:page_data, page_data)
      |> assign(:rendered_content, result)
    rescue
      e ->
        assign(socket, :error, "编译错误: #{Exception.message(e)}")
    end
  end

  defp dispatch_backend(event, params, socket) do
    state = Map.get(socket.assigns, :page_data, %{})

    result =
      call_backend(
        socket.assigns.page_backend,
        event,
        %{"__page_id" => socket.assigns.page} |> Map.merge(stringify_map(params)),
        state
      )

    apply_backend_result(socket, result)
  end

  defp call_backend(backend, event, params, state) do
    if function_exported?(backend, :dispatch, 3) do
      backend.dispatch(event, params, stringify_map(state))
    else
      {:error, :page_backend_not_available}
    end
  end

  defp apply_backend_result(socket, {:ok, %{dto: dto, status: status} = result}) do
    page_data =
      socket.assigns.page_data
      |> merge_backend_payload(dto, status)
      |> maybe_put_flash_from_effects(
        Map.get(result, :effects) || Map.get(result, "effects") || []
      )

    socket =
      socket
      |> apply_effects(Map.get(result, :effects) || Map.get(result, "effects") || [])
      |> render_page(socket.assigns.page_template_content, page_data)

    assign(socket, :error, nil)
  end

  defp apply_backend_result(socket, {:error, reason}) do
    socket
    |> put_flash(:error, inspect(reason))
    |> assign(:error, inspect(reason))
  end

  defp apply_backend_result(socket, _other), do: socket

  defp merge_backend_payload(page_data, dto, status) do
    page_data
    |> Map.merge(deep_atomize_keys(normalize_map(dto)))
    |> Map.merge(deep_atomize_keys(normalize_map(status)))
  end

  defp maybe_put_flash_from_effects(page_data, effects) do
    case Enum.find(normalize_effects(effects), &match?(%{type: "flash"}, &1)) do
      %{kind: kind, message: message} ->
        Map.put(page_data, :flash_preview, %{kind: kind, message: message})

      _ ->
        page_data
    end
  end

  defp apply_effects(socket, effects) do
    Enum.reduce(normalize_effects(effects), socket, fn effect, acc ->
      case effect do
        %{type: "patch", to: to} when is_binary(to) ->
          push_patch(acc, to: to)

        %{type: "navigate", to: to} when is_binary(to) ->
          push_navigate(acc, to: to)

        %{type: "flash", kind: kind, message: message}
        when is_binary(kind) and is_binary(message) ->
          put_flash(acc, String.to_atom(kind), message)

        _ ->
          acc
      end
    end)
  end

  defp normalize_effects(effects) when is_list(effects) do
    Enum.map(effects, fn effect ->
      effect
      |> normalize_map()
      |> deep_atomize_keys()
    end)
  end

  defp normalize_effects(_effects), do: []

  defp normalize_map(map) when is_map(map) do
    Enum.into(map, %{}, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} -> {key, value}
    end)
  end

  defp normalize_map(_map), do: %{}

  defp deep_atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, val}, acc ->
      atom_key = if is_binary(key), do: String.to_atom(key), else: key
      Map.put(acc, atom_key, deep_atomize_keys(val))
    end)
  end

  defp deep_atomize_keys(value) when is_list(value), do: Enum.map(value, &deep_atomize_keys/1)
  defp deep_atomize_keys(value), do: value

  defp stringify_map(value) when is_map(value) do
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

  defp stringify_map(value) when is_list(value), do: Enum.map(value, &stringify_map/1)
  defp stringify_map(value), do: value

  defp runtime_mode do
    case Application.get_env(:hospital_scheduling, :scheduling_page_runtime, :mock) do
      :graphql -> :graphql
      "graphql" -> :graphql
      _ -> :mock
    end
  end

  defp page_backend do
    Application.get_env(
      :hospital_scheduling,
      :scheduling_page_backend,
      HospitalSchedulingWeb.Graphql.StitchBackend
    )
  end

  defp pages_dir do
    Application.get_env(:hospital_scheduling, :scheduling_pages_dir, @default_pages_dir)
  end

  defp list_pages do
    case manifest_pages() do
      [] -> list_pages_from_directory()
      pages -> pages
    end
  end

  defp manifest_pages do
    frontend_manifest = HospitalSchedulingWeb.Graphql.RuntimeConfig.frontend_manifest()

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

  defp list_pages_from_directory do
    if File.dir?(pages_dir()) do
      pages_dir()
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".heex"))
      |> Enum.map(fn f ->
        name =
          f
          |> String.replace_suffix(".expanded.generated.heex", "")
          |> String.replace_suffix(".generated.heex", "")
          |> String.replace_suffix(".heex", "")

        %{name: name, file: f}
      end)
      |> Enum.sort_by(& &1.name)
      |> Enum.uniq_by(& &1.name)
    else
      []
    end
  end

  @impl true
  def render(%{page: nil} = assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-8">
      <h1 class="text-2xl font-bold mb-6">排班管理页面一览</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for p <- @pages do %>
          <a
            href={Map.get(p, :route, "/scheduling/#{p.name}")}
            class="block p-4 bg-white rounded-lg shadow hover:shadow-md transition-shadow border"
          >
            <div class="font-medium text-blue-600">{p.name}</div>
            <div class="text-sm text-gray-500 mt-1">
              {Map.get(p, :route, p.file)}
            </div>
          </a>
        <% end %>
      </div>
    </div>
    """
  end

  def render(%{error: error} = assigns) when not is_nil(error) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen">
      <div class="bg-white p-8 rounded-lg shadow-lg max-w-md">
        <h1 class="text-xl font-bold text-red-600 mb-4">渲染错误</h1>
        <p class="text-gray-600 mb-4 whitespace-pre-wrap">{@error}</p>
        <a href="/scheduling" class="text-blue-600 hover:underline">返回页面列表</a>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen" data-page={@page}>
      <div class="fixed top-2 right-2 z-50 flex gap-2">
        <a
          href="/scheduling"
          class="bg-black/70 text-white px-3 py-1.5 rounded text-sm hover:bg-black/85"
        >
          ← 列表
        </a>
      </div>
      {@rendered_content}
    </div>
    """
  end

  defp normalize_list(values) when is_list(values), do: values
  defp normalize_list(_values), do: []

  defp normalize_string(nil), do: ""
  defp normalize_string(value) when is_binary(value), do: String.trim(value)
  defp normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  defp normalize_string(value), do: value |> to_string() |> String.trim()

  defp map_get(map, key) when is_map(map) and is_atom(key), do: map_get(map, Atom.to_string(key))

  defp map_get(map, key) when is_map(map) and is_binary(key) do
    Enum.find_value(map, fn
      {existing_key, value} when is_binary(existing_key) and existing_key == key ->
        value

      {existing_key, value} when is_atom(existing_key) ->
        if Atom.to_string(existing_key) == key, do: value, else: nil

      _ ->
        nil
    end)
  end

  defp map_get(_map, _key), do: nil
end
