defmodule UniboExPocWeb.TravelLive do
  @moduledoc """
  Travel 页面动态渲染 LiveView。
  从 priv/static/travel_pages/travel/ 加载 .generated.heex 文件，
  动态编译并渲染，使用 StitchUI 组件库。
  """
  use Phoenix.LiveView, layout: {UniboExPocWeb.Layouts, :app}

  alias UniboExPocWeb.Live.TravelPageHostRuntime, as: Runtime

  @impl true
  def mount(%{"page" => page} = params, _session, socket) do
    socket =
      socket
      |> assign(:page, page)
      |> assign(:page_params, Map.delete(params, "page"))
      |> assign(:error, nil)
      |> assign(:rendered_content, nil)
      |> load_and_render(page)

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page, nil)
      |> assign(:error, nil)
      |> assign(:rendered_content, nil)
      |> assign(:pages, Runtime.list_pages())

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
    {:noreply, assign(socket, :pages, Runtime.list_pages())}
  end

  @impl true
  def handle_event("navigate:" <> path, _params, socket) do
    {:noreply, push_navigate(socket, to: path)}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp load_and_render(socket, page) do
    case Runtime.load_page(page, %{}, :mock, nil) do
      {:ok, %{content: content, page_data: page_data}} ->
        render_page(socket, content, page_data)

      {:error, message} ->
        assign(socket, :error, message)
    end
  end

  defp render_page(socket, content, page_data) do
    try do
      module_name = :"Elixir.TravelDynamic.Render#{:erlang.unique_integer([:positive])}"
      indented_content = indent_template(content)

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
      #{indented_content}
          \"\"\"
        end
      end
      """

      Code.compile_string(module_code)

      assigns =
        page_data
        |> Map.put(:flash, Map.get(socket.assigns, :flash, %{}))
        |> Map.put(:__changed__, nil)

      result = apply(module_name, :render, [assigns])

      :code.purge(module_name)
      :code.delete(module_name)

      assign(socket, :rendered_content, result)
    rescue
      e ->
        assign(socket, :error, "编译错误: #{Exception.message(e)}")
    end
  end

  defp indent_template(content) do
    content
    |> String.split("\n", trim: false)
    |> Enum.map_join("\n", fn line -> "          " <> line end)
  end

  @impl true
  def render(%{page: nil} = assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-8">
      <h1 class="text-2xl font-bold mb-6">Travel 页面一览</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for p <- @pages do %>
          <a
            href={Map.get(p, :route, "/travel/#{p.name}")}
            class="block p-4 bg-white rounded-lg shadow hover:shadow-md transition-shadow border"
          >
            <div class="font-medium text-blue-600">{p.name}</div>
            <div class="text-sm text-gray-500 mt-1">{Map.get(p, :route, p.file)}</div>
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
        <a href="/travel" class="text-blue-600 hover:underline">返回页面列表</a>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
      <div class="fixed top-2 right-2 z-50 flex gap-2">
        <a
          href="/travel"
          class="bg-black/70 text-white px-3 py-1.5 rounded text-sm hover:bg-black/85"
        >
          ← 列表
        </a>
      </div>
      {@rendered_content}
    </div>
    """
  end
end
