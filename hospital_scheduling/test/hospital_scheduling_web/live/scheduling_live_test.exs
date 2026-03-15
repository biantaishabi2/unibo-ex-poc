defmodule HospitalSchedulingWeb.SchedulingLiveTest do
  use HospitalSchedulingWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  defmodule FakeBackend do
    def dispatch("__load__", %{"__page_id" => "solver_result"}, _state) do
      {:ok,
       %{
         dto: %{"period" => %{"title" => "ICU 四月排班"}},
         status: %{"run" => %{"status" => "generated"}},
         effects: [],
         errors: [],
         meta: %{}
       }}
    end

    def dispatch("__load__", %{"__page_id" => "load_failure"}, _state) do
      {:error, :load_failed}
    end

    def dispatch("action_publish", %{"__page_id" => "solver_result"}, _state) do
      {:ok,
       %{
         dto: %{},
         status: %{"run" => %{"status" => "published"}},
         effects: [%{"type" => "flash", "kind" => "info", "message" => "发布成功"}],
         errors: [],
         meta: %{}
       }}
    end

    def dispatch("action_fail", %{"__page_id" => "solver_result"}, _state) do
      {:error, :backend_failed}
    end

    def dispatch(_event, _params, state) do
      {:ok, %{dto: state, status: %{}, effects: [], errors: [], meta: %{}}}
    end
  end

  setup do
    tmp_dir =
      Path.join(
        System.tmp_dir!(),
        "hospital_scheduling_live_test_#{System.unique_integer([:positive])}"
      )

    File.rm_rf(tmp_dir)
    File.mkdir_p!(tmp_dir)

    previous_runtime = Application.get_env(:hospital_scheduling, :scheduling_page_runtime)
    previous_backend = Application.get_env(:hospital_scheduling, :scheduling_page_backend)
    previous_pages_dir = Application.get_env(:hospital_scheduling, :scheduling_pages_dir)

    previous_runtime_config =
      Application.get_env(:hospital_scheduling, HospitalSchedulingWeb.Graphql.RuntimeConfig, [])

    on_exit(fn ->
      restore_env(:scheduling_page_runtime, previous_runtime)
      restore_env(:scheduling_page_backend, previous_backend)
      restore_env(:scheduling_pages_dir, previous_pages_dir)

      Application.put_env(
        :hospital_scheduling,
        HospitalSchedulingWeb.Graphql.RuntimeConfig,
        previous_runtime_config
      )

      File.rm_rf(tmp_dir)
    end)

    {:ok, tmp_dir: tmp_dir, previous_runtime_config: previous_runtime_config}
  end

  test "mock 模式下会读取 mock 数据并渲染页面", %{conn: conn, tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "solver_result", """
    <div id="page_title"><%= @period[:title] %></div>
    <div id="run_status"><%= @run[:status] %></div>
    """)

    write_status_defaults!(tmp_dir, "solver_result", %{
      "period" => %{"title" => ""},
      "run" => %{"status" => "draft"}
    })

    write_mock!(tmp_dir, "solver_result", %{
      "period" => %{"title" => "手工排班草稿"}
    })

    Application.put_env(:hospital_scheduling, :scheduling_page_runtime, :mock)
    Application.put_env(:hospital_scheduling, :scheduling_pages_dir, tmp_dir)

    {:ok, _view, html} = live(conn, "/scheduling/solver_result")

    assert html =~ "手工排班草稿"
    assert html =~ "draft"
  end

  test "graphql 模式下首屏 load 失败会展示错误", %{conn: conn, tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "load_failure", """
    <div id="page_title"><%= @period[:title] %></div>
    """)

    write_status_defaults!(tmp_dir, "load_failure", %{
      "period" => %{"title" => ""}
    })

    set_graphql_runtime!(tmp_dir, %{
      "pages" => [%{"page_id" => "load_failure", "page_type" => "composition"}],
      "route_map" => [%{"page_id" => "load_failure", "path" => "/scheduling/load_failure"}]
    })

    {:ok, _view, html} = live(conn, "/scheduling/load_failure")

    assert html =~ "渲染错误"
    assert html =~ "页面加载失败: :load_failed"
  end

  test "graphql 模式下 mount 会走 backend load，事件会重渲染页面", %{conn: conn, tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "solver_result", """
    <div id="page_title"><%= @period[:title] %></div>
    <div id="run_status"><%= @run[:status] %></div>
    <div id="flash_preview"><%= @flash_preview[:message] %></div>
    <button id="publish_btn" phx-click="action_publish">发布</button>
    """)

    write_status_defaults!(tmp_dir, "solver_result", %{
      "period" => %{"title" => ""},
      "run" => %{"status" => ""}
    })

    set_graphql_runtime!(tmp_dir, %{
      "pages" => [%{"page_id" => "solver_result", "page_type" => "composition"}],
      "route_map" => [%{"page_id" => "solver_result", "path" => "/scheduling/periods/:id/result"}]
    })

    {:ok, view, html} = live(conn, "/scheduling/solver_result")

    assert html =~ "ICU 四月排班"
    assert html =~ "generated"

    html =
      view
      |> element("#publish_btn")
      |> render_click()

    assert html =~ "published"
    assert html =~ "发布成功"
  end

  test "graphql 模式下 backend 失败会展示错误", %{conn: conn, tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "solver_result", """
    <div id="page_title"><%= @period[:title] %></div>
    <button id="fail_btn" phx-click="action_fail">失败</button>
    """)

    write_status_defaults!(tmp_dir, "solver_result", %{
      "period" => %{"title" => ""}
    })

    set_graphql_runtime!(tmp_dir, %{
      "pages" => [%{"page_id" => "solver_result", "page_type" => "composition"}],
      "route_map" => [%{"page_id" => "solver_result", "path" => "/scheduling/periods/:id/result"}]
    })

    {:ok, view, _html} = live(conn, "/scheduling/solver_result")

    html =
      view
      |> element("#fail_btn")
      |> render_click()

    assert html =~ ":backend_failed"
    assert html =~ "渲染错误"
  end

  test "列表页优先展示 frontend manifest 里的页面和路由", %{conn: conn, tmp_dir: tmp_dir} do
    set_graphql_runtime!(tmp_dir, %{
      "pages" => [
        %{"page_id" => "solver_result", "page_type" => "composition"},
        %{"page_id" => "publish_preview", "page_type" => "composition"}
      ],
      "route_map" => [
        %{"page_id" => "solver_result", "path" => "/scheduling/periods/:id/result"},
        %{"page_id" => "publish_preview", "path" => "/scheduling/periods/:id/publish"}
      ]
    })

    {:ok, _view, html} = live(conn, "/scheduling")

    assert html =~ "solver_result"
    assert html =~ "/scheduling/periods/:id/result"
    assert html =~ "publish_preview"
    assert html =~ "/scheduling/periods/:id/publish"
  end

  test "manifest 缺失时列表页回退到目录扫描", %{conn: conn, tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "calendar_adjustment", "<div>calendar_adjustment</div>")
    write_page!(tmp_dir, "solver_result", "<div>solver_result</div>")

    Application.put_env(:hospital_scheduling, :scheduling_page_runtime, :mock)
    Application.put_env(:hospital_scheduling, :scheduling_pages_dir, tmp_dir)

    Application.put_env(
      :hospital_scheduling,
      HospitalSchedulingWeb.Graphql.RuntimeConfig,
      frontend_manifest: Path.join(tmp_dir, "missing.frontend_manifest.v1.json")
    )

    {:ok, _view, html} = live(conn, "/scheduling")

    assert html =~ "calendar_adjustment"
    assert html =~ "/scheduling/calendar_adjustment"
    assert html =~ "solver_result"
    assert html =~ "/scheduling/solver_result"
  end

  defp set_graphql_runtime!(tmp_dir, frontend_manifest) do
    frontend_manifest_path = Path.join(tmp_dir, "frontend_manifest.v1.json")
    File.write!(frontend_manifest_path, Jason.encode!(frontend_manifest))

    Application.put_env(:hospital_scheduling, :scheduling_page_runtime, :graphql)
    Application.put_env(:hospital_scheduling, :scheduling_page_backend, FakeBackend)
    Application.put_env(:hospital_scheduling, :scheduling_pages_dir, tmp_dir)

    Application.put_env(
      :hospital_scheduling,
      HospitalSchedulingWeb.Graphql.RuntimeConfig,
      frontend_manifest: frontend_manifest_path
    )
  end

  defp write_page!(tmp_dir, page, body) do
    File.write!(Path.join(tmp_dir, "#{page}.expanded.generated.heex"), body)
  end

  defp write_mock!(tmp_dir, page, payload) do
    File.write!(
      Path.join(tmp_dir, "#{page}.expanded.mock.json"),
      Jason.encode!(payload)
    )
  end

  defp write_status_defaults!(tmp_dir, page, defaults) do
    File.write!(
      Path.join(tmp_dir, "#{page}.expanded.status.schema.v1.json"),
      Jason.encode!(%{"defaults" => defaults})
    )
  end

  defp restore_env(key, nil), do: Application.delete_env(:hospital_scheduling, key)
  defp restore_env(key, value), do: Application.put_env(:hospital_scheduling, key, value)
end
