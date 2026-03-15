defmodule HospitalSchedulingWeb.SchedulingLive do
  @moduledoc """
  标准化页面宿主。

  负责：
  - 默认入口和页面列表展示
  - 调用 runtime adapter 加载页面数据
  - 将 backend effects 应用到 LiveView socket
  """
  use Phoenix.LiveView, layout: {HospitalSchedulingWeb.Layouts, :app}

  alias HospitalSchedulingWeb.Live.PageHostRuntime

  @impl true
  def mount(%{"page" => page} = params, _session, socket) do
    socket =
      socket
      |> assign(:runtime_mode, PageHostRuntime.runtime_mode())
      |> assign(:page_backend, PageHostRuntime.page_backend())
      |> assign(:page, page)
      |> assign(:page_params, Map.delete(params, "page"))
      |> assign(:error, nil)
      |> assign(:page_source_path, nil)
      |> assign(:page_template_content, nil)
      |> assign(:page_data, PageHostRuntime.default_assigns())
      |> assign(:rendered_content, nil)
      |> load_and_render(page, Map.delete(params, "page"))

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:runtime_mode, PageHostRuntime.runtime_mode())
      |> assign(:page_backend, PageHostRuntime.page_backend())
      |> assign(:page, nil)
      |> assign(:error, nil)
      |> assign(:page_source_path, nil)
      |> assign(:page_template_content, nil)
      |> assign(:page_data, PageHostRuntime.default_assigns())
      |> assign(:rendered_content, nil)
      |> assign(:pages, PageHostRuntime.list_pages())

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
    {:noreply, assign(socket, :pages, PageHostRuntime.list_pages())}
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
    case PageHostRuntime.load_page(
           page,
           params,
           socket.assigns.runtime_mode,
           socket.assigns.page_backend
         ) do
      {:ok, %{path: path, content: content, page_data: page_data}} ->
        socket
        |> assign(:page_source_path, path)
        |> assign(:page_template_content, content)
        |> render_page(content, page_data)
        |> assign(:error, nil)

      {:error, message} ->
        assign(socket, :error, message)
    end
  end

  defp render_page(socket, content, page_data) do
    try do
      module_name = :"Elixir.SchedulingDynamic.Render#{:erlang.unique_integer([:positive])}"
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
        PageHostRuntime.default_assigns()
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

  defp indent_template(content) do
    content
    |> String.split("\n", trim: false)
    |> Enum.map_join("\n", fn line -> "          " <> line end)
  end

  defp dispatch_backend(event, params, socket) do
    result =
      PageHostRuntime.dispatch(
        socket.assigns.page_backend,
        socket.assigns.page,
        event,
        params,
        Map.get(socket.assigns, :page_data, %{})
      )

    apply_backend_result(socket, result)
  end

  defp apply_backend_result(socket, {:ok, %{dto: dto, status: status} = result}) do
    page_data =
      socket.assigns.page_data
      |> PageHostRuntime.merge_backend_payload(dto, status)
      |> PageHostRuntime.maybe_put_flash_from_effects(
        Map.get(result, :effects) || Map.get(result, "effects") || []
      )

    socket
    |> apply_effects(Map.get(result, :effects) || Map.get(result, "effects") || [])
    |> render_page(socket.assigns.page_template_content, page_data)
    |> assign(:error, nil)
  end

  defp apply_backend_result(socket, {:error, reason}) do
    socket
    |> put_flash(:error, inspect(reason))
    |> assign(:error, inspect(reason))
  end

  defp apply_backend_result(socket, _other), do: socket

  defp apply_effects(socket, effects) do
    Enum.reduce(PageHostRuntime.normalize_effects(effects), socket, fn effect, acc ->
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
        <a href="/scheduling" class="text-blue-600 hover:underline">返回页面列表</a>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
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
end
