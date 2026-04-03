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

    # tenant fallback: URL 参数 → socket assigns → 配置默认值
    tenant_id =
      query_params["tenant_id"] ||
        socket.assigns[:tenant_id] ||
        PageHostRuntime.default_tenant_id()

    socket = if tenant_id, do: assign(socket, :tenant_id, tenant_id), else: socket

    socket =
      case PageHostRuntime.resolve_host_route(route_segments, query_params) do
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
    # 第一层：前端导航事件（manifest transitions）
    case PageHostRuntime.event_navigate_to(socket.assigns.page, event, params || %{}) do
      {:ok, target} ->
        {:noreply, push_navigate(socket, to: PageHostRuntime.normalize_host_target(target, socket.assigns.page))}
      :none ->
        handle_event_dispatch(event, params, socket)
    end
  end

  # 第二层：前端状态事件
  defp handle_event_dispatch("toggle_edit", _params, socket) do
    page_data = Map.update(socket.assigns.page_data, :editing, true, &(!&1))
    {:noreply, render_page(socket, socket.assigns.page_template_content, page_data)}
  end

  defp handle_event_dispatch("cancel_edit", _params, socket) do
    page_data = Map.put(socket.assigns.page_data, :editing, false)
    {:noreply, render_page(socket, socket.assigns.page_template_content, page_data)}
  end

  defp handle_event_dispatch("form_change", params, socket) do
    page_data = merge_form_params(socket.assigns.page_data, params)
    {:noreply, render_page(socket, socket.assigns.page_template_content, page_data)}
  end

  # 第三层：后端事件
  defp handle_event_dispatch(event, params, socket) do
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
    # 把 socket 上的 tenant_id 注入 params，使 load_page 能传递给 backend state
    params =
      case socket.assigns[:tenant_id] do
        nil -> params
        tid -> Map.put_new(params, "tenant_id", tid)
      end

    case PageHostRuntime.load_page(
           page_id,
           params,
           socket.assigns.runtime_mode,
           socket.assigns.page_backend
         ) do
      {:ok, %{path: path, content: content, page_data: page_data}} ->
        # 创建模式：id=="new" 时自动进入编辑态
        page_data =
          if create_mode?(params) do
            page_data |> Map.put(:editing, true) |> Map.put(:create_mode, true)
          else
            page_data |> Map.put(:create_mode, false)
          end

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
    # 组件调用 <.xxx>、闭合标签 </xxx>、EEx 标签 <%= 是合法标签，不转义
    if next in [".", "/", "%"] do
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

  defp merge_form_params(page_data, params) when is_map(params) do
    Enum.reduce(params, page_data, fn
      {"_target", _}, acc -> acc
      {"_csrf_token", _}, acc -> acc
      {key, value}, acc when is_map(value) ->
        # 嵌套 key（如 "travel_airline" => %{"airline_code" => "..."}）→ 合并到同名 atom key
        existing = Map.get(acc, String.to_atom(key), Map.get(acc, key, %{}))
        merged = if is_map(existing), do: deep_merge_form(existing, value), else: value
        acc |> Map.put(String.to_atom(key), merged) |> Map.put(key, merged)
      {key, value}, acc ->
        acc |> Map.put(String.to_atom(key), value) |> Map.put(key, value)
    end)
  end

  defp merge_form_params(page_data, _params), do: page_data

  defp deep_merge_form(existing, new) when is_map(existing) and is_map(new) do
    Map.merge(existing, new, fn
      _k, v1, v2 when is_map(v1) and is_map(v2) -> deep_merge_form(v1, v2)
      _k, _v1, v2 -> v2
    end)
  end

  defp deep_merge_form(_existing, new), do: new

  defp create_mode?(params) when is_map(params) do
    id = PageHostRuntime.normalize_string(Map.get(params, "id", Map.get(params, :id)))
    id == "new"
  end

  defp create_mode?(_params), do: false

  defp dispatch_backend(event, params, socket) do
    merged_params =
      socket.assigns
      |> Map.get(:page_params, %{})
      |> Map.merge(PageHostRuntime.stringify_map(params || %{}))

    # 创建模式下清空 id，让 StitchBackend 走 create 路径
    merged_params =
      if Map.get(socket.assigns.page_data, :create_mode, false) do
        Map.delete(merged_params, "id")
      else
        merged_params
      end

    # 确保 tenant_id 始终在 state 中，供 StitchBackend.context_from_state 使用
    state =
      case socket.assigns[:tenant_id] do
        nil -> Map.get(socket.assigns, :page_data, %{})
        tid -> Map.get(socket.assigns, :page_data, %{}) |> Map.put_new("tenant_id", tid)
      end

    result =
      PageHostRuntime.dispatch(
        socket.assigns.page_backend,
        socket.assigns.page,
        event,
        merged_params,
        state
      )

    apply_backend_result(socket, result)
  end

  defp apply_backend_result(socket, {:ok, %{dto: dto, status: status} = result}) do
    effects = Map.get(result, :effects) || Map.get(result, "effects") || []
    errors = Map.get(result, :errors) || Map.get(result, "errors") || []

    page_data =
      socket.assigns.page_data
      |> PageHostRuntime.merge_backend_payload(dto, status)
      |> PageHostRuntime.maybe_put_flash_from_effects(effects)

    # 从 meta 获取 api_key，用于判断操作类型
    meta = Map.get(result, :meta) || Map.get(result, "meta") || %{}
    api_key = PageHostRuntime.normalize_string(Map.get(meta, "api_key") || Map.get(meta, :api_key))

    # 删除成功后，跳转回列表页
    if api_key == "destroy" and errors == [] do
      page_id = PageHostRuntime.normalize_string(Map.get(socket.assigns, :page, ""))
      # detail page_id 形如 "entity_detail"，对应列表页为 "entity_list"
      list_page_id = String.replace_suffix(page_id, "_detail", "_list")

      list_path =
        PageHostRuntime.normalize_list(UniboExPocWeb.Graphql.RuntimeConfig.frontend_route_map())
        |> Enum.find_value(fn route ->
          if PageHostRuntime.normalize_string(PageHostRuntime.map_get(route, "page_id")) == list_page_id do
            PageHostRuntime.primary_route_path(
              PageHostRuntime.normalize_string(PageHostRuntime.map_get(route, "path")),
              PageHostRuntime.normalize_string(PageHostRuntime.map_get(route, "full_path"))
            )
          end
        end)

      target_path =
        case list_path do
          path when is_binary(path) and path != "" -> path
          _ ->
            # 回退：从 page_id 推导路径
            "/" <> String.replace(list_page_id, "_", "/")
        end

      target = PageHostRuntime.normalize_host_target(target_path, list_page_id)

      socket
      |> put_flash(:info, "删除成功")
      |> push_navigate(to: target)
    else
    # 创建模式成功后，跳转到新记录详情页
    create_mode = Map.get(socket.assigns.page_data, :create_mode, false)
    new_id =
      (Map.get(dto, :id) || Map.get(dto, "id") ||
       Map.get(Map.get(dto, :record, %{}), :id) ||
       Map.get(Map.get(dto, "record", %{}), "id"))
      |> PageHostRuntime.normalize_string()

    if create_mode and new_id != "" and errors == [] do
      # 创建成功 → 从路由表查找页面路由模式，将 :id 替换为新 id，安全跳转到详情页
      page_id = PageHostRuntime.normalize_string(Map.get(socket.assigns, :page, ""))
      route_path =
        PageHostRuntime.normalize_list(UniboExPocWeb.Graphql.RuntimeConfig.frontend_route_map())
        |> Enum.find_value(fn route ->
          if PageHostRuntime.normalize_string(PageHostRuntime.map_get(route, "page_id")) == page_id do
            PageHostRuntime.primary_route_path(
              PageHostRuntime.normalize_string(PageHostRuntime.map_get(route, "path")),
              PageHostRuntime.normalize_string(PageHostRuntime.map_get(route, "full_path"))
            )
          end
        end)

      target_path =
        case route_path do
          path when is_binary(path) and path != "" ->
            # 将路由模式中的 :id 参数替换为实际 new_id
            Regex.replace(~r/:id\b/, path, new_id)
          _ ->
            # 回退：page_id 转路径，末尾拼 new_id
            "/" <> String.replace(page_id, "_", "/") <> "/" <> new_id
        end

      target = PageHostRuntime.normalize_host_target(target_path, page_id)
      push_navigate(socket, to: target)
    else
      if errors != [] do
        error_msg = errors |> Enum.map(&(Map.get(&1, "message") || Map.get(&1, :message) || "")) |> Enum.join("; ")
        socket
        |> put_flash(:error, error_msg)
        |> render_page(socket.assigns.page_template_content, page_data)
      else
        socket
        |> apply_effects(effects)
        |> render_page(socket.assigns.page_template_content, page_data)
      end
    end
    end
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
