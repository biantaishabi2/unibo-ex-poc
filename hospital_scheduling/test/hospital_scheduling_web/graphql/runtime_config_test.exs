defmodule HospitalSchedulingWeb.Graphql.RuntimeConfigTest do
  use ExUnit.Case, async: false

  alias HospitalSchedulingWeb.Graphql.RuntimeConfig

  setup do
    tmp_dir =
      System.tmp_dir!()
      |> Path.join("hospital_scheduling-runtime-config-#{System.unique_integer([:positive])}")

    File.mkdir_p!(tmp_dir)

    frontend_manifest_path = Path.join(tmp_dir, "frontend_manifest.v1.json")
    graphql_manifest_path = Path.join(tmp_dir, "manifest.json")

    original =
      Application.get_env(:hospital_scheduling, RuntimeConfig, [])

    Application.put_env(
      :hospital_scheduling,
      RuntimeConfig,
      Keyword.merge(original,
        frontend_manifest: frontend_manifest_path,
        manifest: graphql_manifest_path
      )
    )

    File.write!(graphql_manifest_path, Jason.encode!(%{"fields" => []}))

    on_exit(fn ->
      Application.put_env(:hospital_scheduling, RuntimeConfig, original)
      File.rm_rf(tmp_dir)
    end)

    {:ok, frontend_manifest_path: frontend_manifest_path}
  end

  test "frontend_manifest_report 标准化 pages 和 route_map", %{
    frontend_manifest_path: frontend_manifest_path
  } do
    File.write!(
      frontend_manifest_path,
      Jason.encode!(%{
        "pages" => [
          %{
            "page_id" => "scheduling_period_list",
            "page_type" => "list_report",
            "backend" => %{"api_map" => %{"list" => "Scheduling.SchedulingPeriod.list"}},
            "status_keys" => ["rows", "loading"]
          },
          %{
            "page_id" => "solver_result",
            "page_type" => "custom",
            "backend" => %{"api_map" => %{"get" => "Scheduling.SolverRun.get"}},
            "status_keys" => ["record", "loading"]
          }
        ],
        "route_map" => [
          %{"path" => "/scheduling/periods", "page_id" => "scheduling_period_list"},
          %{"path" => "/scheduling/solver_result", "page_id" => "solver_result"}
        ]
      })
    )

    report = RuntimeConfig.frontend_manifest_report()

    assert report.errors == []
    assert report.warnings == []
    assert Enum.count(report.pages) == 2
    assert Enum.count(report.route_map) == 2

    assert {:ok, page} = RuntimeConfig.frontend_page("solver_result")
    assert page["route_path"] == "/scheduling/solver_result"
    assert page["api_map"] == %{"get" => "Scheduling.SolverRun.get"}
  end

  test "frontend_manifest_report 暴露 route_map 和 page 定义不一致", %{
    frontend_manifest_path: frontend_manifest_path
  } do
    File.write!(
      frontend_manifest_path,
      Jason.encode!(%{
        "pages" => [
          %{
            "page_id" => "scheduling_period_list",
            "page_type" => "list_report",
            "backend" => %{"api_map" => %{"list" => "Scheduling.SchedulingPeriod.list"}}
          }
        ],
        "route_map" => [
          %{"path" => "/scheduling/missing", "page_id" => "missing_page"}
        ]
      })
    )

    report = RuntimeConfig.frontend_manifest_report()

    assert [
             %{
               "code" => "route_map_unknown_page",
               "page_id" => "missing_page",
               "path" => "/scheduling/missing",
               "severity" => "error"
             }
           ] = report.errors
  end
end