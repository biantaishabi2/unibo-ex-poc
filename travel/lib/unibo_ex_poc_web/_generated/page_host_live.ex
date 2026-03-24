defmodule UniboExPocWeb.Generated.PageHostLive do
  @moduledoc """
  通用页面宿主 LiveView（由 UniBO 自动生成）。
  """
  use Phoenix.LiveView, layout: { UniboExPocWeb.Layouts, :app }

  alias UniboExPocWeb.Generated.PageHostRuntime

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:runtime_mode, PageHostRuntime.runtime_mode())
     |> assign(:page_backend, PageHostRuntime.page_backend())
     |> assign(:page, nil)
     |> assign(:page_params, %{})
     |> assign(:error, nil)
     |> assign(:page_source_path, nil)
     |> assign(:page_template_content, nil)
     |> assign(:page_data, PageHostRuntime.default_assigns())
     |> assign(:rendered_content, nil)
     |> assign(:pages, PageHostRuntime.list_pages())}
  end

  @impl true
  def handle_params(%{"route_segments" => route_segments} = params, _uri, socket) do
    query_params = Map.drop(params, ["route_segments"])

    socket =
      case PageHostRuntime.resolve_host_route(route_segments) do
        {:ok, %{page_id: page_id, page_params: page_params}} ->
          merged_params =
            page_params
            |> Map.merge(query_params)
            |> then(&PageHostRuntime.normalize_page_params(page_id, &1))

          socket
          |> assign(:page, page_id)
          |> assign(:page_params, merged_params)
          |> assign(:error, nil)
          |> load_and_render(page_id, merged_params)

        {:error, reason} ->
          socket
          |> assign(:page, nil)
          |> assign(:page_params, %{})
          |> assign(:rendered_content, nil)
          |> assign(:error, inspect(reason))
      end

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:page, nil)
     |> assign(:page_params, %{})
     |> assign(:error, nil)
     |> assign(:pages, PageHostRuntime.list_pages())}
  end

  @impl true
  def handle_event(_event, _params, %{assigns: %{page: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event(event, params, socket) do
    socket =
      case socket.assigns.runtime_mode do
        :graphql ->
          if PageHostRuntime.page_has_backend?(socket.assigns.page) do
            dispatch_backend(event, params, socket)
          else
            socket
          end

        _ ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:page_host_reload, params}, %{assigns: %{page: page}} = socket)
      when is_binary(page) and is_map(params) do
    if PageHostRuntime.supports_reload?(page) do
      merged_params =
        socket.assigns
        |> Map.get(:page_params, %{})
        |> Map.merge(PageHostRuntime.normalize_page_params(page, params))

      {:noreply,
       socket
       |> assign(:page_params, merged_params)
       |> load_and_render(page, merged_params)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_message, socket), do: {:noreply, socket}

  defp load_and_render(socket, page_id, params) do
    case PageHostRuntime.load_page(
           page_id,
           params,
           socket.assigns.runtime_mode,
           socket.assigns.page_backend
         ) do
      {:ok, %{path: path, content: content, page_data: page_data}} ->
        socket
        |> assign(:page_source_path, path)
        |> assign(:page_template_content, content)
        |> render_page(content, page_data)

      {:error, reason} ->
        socket
        |> assign(:rendered_content, nil)
        |> assign(:error, inspect(reason))
    end
  end

  defp render_page(socket, content, page_data) do
    try do
      module_name = :"Elixir.PageHostDynamic.Render#{:erlang.unique_integer([:positive])}"
      indented_content =
        content
        |> sanitize_dynamic_template()
        |> indent_template()

      module_code = """
      defmodule #{module_name} do
        use Phoenix.Component, global_prefixes: ~w(phx-)

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
      |> assign(:error, nil)
    rescue
      e ->
        assign(socket, :error, "page host compile error: " <> Exception.message(e))
    end
  end

  defp indent_template(content) do
    content
    |> String.split("\n", trim: false)
    |> Enum.map_join("\n", fn line -> "          " <> line end)
  end

  # 动态 HEEx 编译时，模型文案里的裸 `<` 会被当成标签起始符。
  # 这里只转义明显像文本比较符的 `<`，避免把真正的标签起始符也误伤。
  defp sanitize_dynamic_template(content) do
    graphemes = String.graphemes(content)

    graphemes
    |> Enum.with_index()
    |> Enum.map_join(fn {grapheme, idx} ->
      if grapheme == "<" and comparison_like_angle_bracket?(graphemes, idx) do
        "&lt;"
      else
        grapheme
      end
    end)
  end

  defp comparison_like_angle_bracket?(graphemes, idx) do
    next = neighboring_grapheme(graphemes, idx + 1)
    # 组件调用 <.xxx> 或闭合标签 </xxx> 是合法标签，不转义
    if next in [".", "/"] do
      false
    else
      prev = neighboring_grapheme(graphemes, idx - 1)
      previous_suggests_text?(prev) or next_suggests_comparison?(next)
    end
  end

  defp neighboring_grapheme(_graphemes, idx) when idx < 0, do: nil
  defp neighboring_grapheme(graphemes, idx), do: Enum.at(graphemes, idx)

  defp previous_suggests_text?(value)
       when value in [nil, " ", "\\n", "\\t", "\\r", ">", "(", "[", "{"] do
    false
  end

  defp previous_suggests_text?(_value), do: true

  defp next_suggests_comparison?(value) when value in [nil, " ", "\\n", "\\t", "\\r", "="] do
    true
  end

  defp next_suggests_comparison?(value), do: String.match?(value, ~r/^\\d$/)

  defp dispatch_backend(event, params, socket) do
    merged_params =
      socket.assigns
      |> Map.get(:page_params, %{})
      |> Map.merge(PageHostRuntime.normalize_page_params(socket.assigns.page, params || %{}))

    result =
      PageHostRuntime.dispatch(
        socket.assigns.page_backend,
        socket.assigns.page,
        event,
        merged_params,
        Map.get(socket.assigns, :page_data, %{})
      )

    apply_backend_result(socket, result)
  end

  defp apply_backend_result(socket, {:ok, %{dto: dto, status: status} = result}) do
    effects = Map.get(result, :effects) || Map.get(result, "effects") || []

    page_data =
      socket.assigns.page_data
      |> PageHostRuntime.merge_backend_payload(dto, status)
      |> PageHostRuntime.maybe_put_flash_from_effects(effects)

    socket
    |> apply_effects(effects)
    |> render_page(socket.assigns.page_template_content, page_data)
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
          push_patch(acc, to: PageHostRuntime.normalize_host_target(to, socket.assigns.page))

        %{type: "navigate", to: to} when is_binary(to) ->
          push_navigate(acc, to: PageHostRuntime.normalize_host_target(to, socket.assigns.page))

        %{type: "flash", kind: kind, message: message}
        when is_binary(kind) and is_binary(message) ->
          put_flash(acc, flash_kind(kind), message)

        _ ->
          acc
      end
    end)
  end

  defp flash_kind("error"), do: :error
  defp flash_kind("info"), do: :info
  defp flash_kind("warning"), do: :error
  defp flash_kind(_), do: :info

  @impl true
  def render(%{page: nil} = assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-8">
      <h1 class="text-2xl font-bold mb-6">页面一览</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for p <- @pages do %>
          <a
            href={Map.get(p, :host_route, PageHostRuntime.host_index_path())}
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
        <a href={PageHostRuntime.host_index_path()} class="text-blue-600 hover:underline">返回页面列表</a>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
      <div class="fixed top-2 right-2 z-50 flex gap-2">
        <a
          href={PageHostRuntime.host_index_path()}
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
