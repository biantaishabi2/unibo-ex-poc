defmodule HospitalSchedulingWeb.SchedulingLive do
  @moduledoc """
  排班管理页面动态渲染 LiveView。
  从 priv/static/scheduling_pages/ 加载 .generated.heex，
  动态编译并渲染，使用 StitchUI 组件库。
  """
  use Phoenix.LiveView, layout: {HospitalSchedulingWeb.Layouts, :app}

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

  @pages_dir Application.compile_env(:hospital_scheduling, :scheduling_pages_dir,
               Path.join(:code.priv_dir(:hospital_scheduling), "static/scheduling_pages"))

  @default_assigns %{
    page_title: "",
    record: %{title: "", state: "", generation_mode: "",
              department: %{name: ""}, start_date: "", end_date: "",
              current_version: %{version_no: ""},
              last_solver_run: %{status: ""},
              schedule_versions: [], solver_runs: []},
    rows: [],
    rows_empty: true,
    period: %{title: "", state: "", start_date: "", end_date: ""},
    run: %{status: "", engine_type: "", hard_violation_count: "",
           warning_count: "", output_snapshot: %{summary: %{
             assignment_count: "", covered_requirement_count: ""}}},
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
    filter: %{}
  }

  @impl true
  def mount(%{"page" => page}, _session, socket) do
    socket =
      socket
      |> assign(:page, page)
      |> assign(:error, nil)
      |> assign(:rendered_content, nil)
      |> load_and_render(page)

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    pages = list_pages()

    socket =
      socket
      |> assign(:page, nil)
      |> assign(:error, nil)
      |> assign(:rendered_content, nil)
      |> assign(:pages, pages)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"page" => page}, _uri, socket) do
    socket =
      socket
      |> assign(:page, page)
      |> assign(:error, nil)
      |> load_and_render(page)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :pages, list_pages())}
  end

  @impl true
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp load_and_render(socket, page) do
    # 尝试多种文件名模式
    candidates = [
      Path.join(@pages_dir, "#{page}.expanded.generated.heex"),
      Path.join(@pages_dir, "#{page}.generated.heex"),
      Path.join(@pages_dir, "#{page}.heex")
    ]

    case Enum.find(candidates, &File.exists?/1) do
      nil ->
        assign(socket, :error, "页面不存在: #{page}")

      file_path ->
        content = File.read!(file_path)
        mock_data = load_mock_data(file_path)
        compile_heex(socket, content, mock_data)
    end
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

  defp compile_heex(socket, content, mock_data) do
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

      assigns = @default_assigns |> Map.merge(mock_data) |> Map.put(:__changed__, nil)
      result = apply(module_name, :render, [assigns])

      :code.purge(module_name)
      :code.delete(module_name)

      assign(socket, :rendered_content, result)
    rescue
      e ->
        assign(socket, :error, "编译错误: #{Exception.message(e)}")
    end
  end

  defp deep_atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, val}, acc ->
      atom_key = if is_binary(key), do: String.to_atom(key), else: key
      Map.put(acc, atom_key, deep_atomize_keys(val))
    end)
  end

  defp deep_atomize_keys(value) when is_list(value), do: Enum.map(value, &deep_atomize_keys/1)
  defp deep_atomize_keys(value), do: value

  defp list_pages do
    if File.dir?(@pages_dir) do
      @pages_dir
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
            href={"/scheduling/#{p.name}"}
            class="block p-4 bg-white rounded-lg shadow hover:shadow-md transition-shadow border"
          >
            <div class="font-medium text-blue-600"><%= p.name %></div>
            <div class="text-sm text-gray-500 mt-1"><%= p.file %></div>
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
        <p class="text-gray-600 mb-4 whitespace-pre-wrap"><%= @error %></p>
        <a href="/scheduling" class="text-blue-600 hover:underline">返回页面列表</a>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
      <div class="fixed top-2 right-2 z-50 flex gap-2">
        <a href="/scheduling" class="bg-black/70 text-white px-3 py-1.5 rounded text-sm hover:bg-black/85">
          ← 列表
        </a>
      </div>
      <%= @rendered_content %>
    </div>
    """
  end
end
