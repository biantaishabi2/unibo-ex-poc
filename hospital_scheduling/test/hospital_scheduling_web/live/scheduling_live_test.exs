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

    heex_path = Path.join(tmp_dir, "solver_result.expanded.generated.heex")
    status_path = Path.join(tmp_dir, "solver_result.expanded.status.schema.v1.json")

    File.write!(
      heex_path,
      """
      <div id="page_title"><%= @period[:title] %></div>
      <div id="run_status"><%= @run[:status] %></div>
      <div id="flash_preview"><%= @flash_preview[:message] %></div>
      <button id="publish_btn" phx-click="action_publish">发布</button>
      """
    )

    File.write!(
      status_path,
      Jason.encode!(%{
        "defaults" => %{
          "period" => %{"title" => ""},
          "run" => %{"status" => ""}
        }
      })
    )

    previous_runtime = Application.get_env(:hospital_scheduling, :scheduling_page_runtime)
    previous_backend = Application.get_env(:hospital_scheduling, :scheduling_page_backend)
    previous_pages_dir = Application.get_env(:hospital_scheduling, :scheduling_pages_dir)

    previous_endpoint =
      Application.get_env(:hospital_scheduling, HospitalSchedulingWeb.Endpoint, [])

    endpoint_config =
      previous_endpoint
      |> Keyword.put(:code_reloader, false)
      |> Keyword.put(:debug_errors, true)

    Application.put_env(:hospital_scheduling, :scheduling_page_runtime, :graphql)
    Application.put_env(:hospital_scheduling, :scheduling_page_backend, FakeBackend)
    Application.put_env(:hospital_scheduling, :scheduling_pages_dir, tmp_dir)
    Application.put_env(:hospital_scheduling, HospitalSchedulingWeb.Endpoint, endpoint_config)

    on_exit(fn ->
      if is_nil(previous_runtime) do
        Application.delete_env(:hospital_scheduling, :scheduling_page_runtime)
      else
        Application.put_env(:hospital_scheduling, :scheduling_page_runtime, previous_runtime)
      end

      if is_nil(previous_backend) do
        Application.delete_env(:hospital_scheduling, :scheduling_page_backend)
      else
        Application.put_env(:hospital_scheduling, :scheduling_page_backend, previous_backend)
      end

      if is_nil(previous_pages_dir) do
        Application.delete_env(:hospital_scheduling, :scheduling_pages_dir)
      else
        Application.put_env(:hospital_scheduling, :scheduling_pages_dir, previous_pages_dir)
      end

      Application.put_env(:hospital_scheduling, HospitalSchedulingWeb.Endpoint, previous_endpoint)

      File.rm_rf(tmp_dir)
    end)

    :ok
  end

  test "graphql 模式下 mount 会走 backend load，事件会重渲染页面", %{conn: conn} do
    {:ok, view, html} = live(conn, "/scheduling/solver_result")

    assert html =~ "ICU 四月排班"
    assert html =~ "generated"

    html =
      view
      |> element("#publish_btn")
      |> render_click()

    assert html =~ "published"
    assert has_element?(view, "#flash_preview", "发布成功")
  end
end
