defmodule HospitalSchedulingWeb.Graphql.StitchBackendContractTest do
  use ExUnit.Case, async: false

  alias HospitalSchedulingWeb.Graphql.RuntimeConfig
  alias HospitalSchedulingWeb.Graphql.StitchBackend

  setup do
    tmp_dir =
      System.tmp_dir!()
      |> Path.join("hospital_scheduling-stitch-backend-#{System.unique_integer([:positive])}")

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

    File.write!(
      graphql_manifest_path,
      Jason.encode!(%{
        "fields" => [
          %{
            "field" => "schedulingPeriodList",
            "entity" => "SchedulingPeriod",
            "mode" => "list",
            "action" => "list"
          },
          %{
            "field" => "solverRunGet",
            "entity" => "SolverRun",
            "mode" => "get",
            "action" => "get"
          }
        ]
      })
    )

    on_exit(fn ->
      Application.put_env(:hospital_scheduling, RuntimeConfig, original)
      File.rm_rf(tmp_dir)
    end)

    {:ok, frontend_manifest_path: frontend_manifest_path}
  end

  test "contract 使用标准化 frontend page contract", %{
    frontend_manifest_path: frontend_manifest_path
  } do
    File.write!(
      frontend_manifest_path,
      Jason.encode!(%{
        "pages" => [
          %{
            "page_id" => "solver_result",
            "page_type" => "custom",
            "backend" => %{"api_map" => %{"get" => "Scheduling.SolverRun.get"}},
            "status_keys" => ["record", "loading"]
          }
        ],
        "route_map" => %{
          "/scheduling/solver_result" => "solver_result"
        }
      })
    )

    assert {:ok, contract} = StitchBackend.contract("solver_result")
    assert get_in(contract, ["backend", "api_map"]) == %{"get" => "Scheduling.SolverRun.get"}
    assert contract["page_id"] == "solver_result"
  end

  test "custom page 缺失 api_map 时显式失败", %{
    frontend_manifest_path: frontend_manifest_path
  } do
    File.write!(
      frontend_manifest_path,
      Jason.encode!(%{
        "pages" => [
          %{
            "page_id" => "solver_result",
            "page_type" => "custom",
            "status_keys" => ["record", "loading"]
          }
        ],
        "route_map" => %{
          "/scheduling/solver_result" => "solver_result"
        }
      })
    )

    assert {:error, {:stitch_backend_page_contract_invalid, details}} =
             StitchBackend.contract("solver_result")

    assert details["page_id"] == "solver_result"

    assert Enum.any?(details["issues"], fn issue ->
             issue["code"] == "custom_page_api_map_missing" and issue["severity"] == "warning"
           end)
  end

  test "manifest error 会阻断 backend contract", %{
    frontend_manifest_path: frontend_manifest_path
  } do
    File.write!(
      frontend_manifest_path,
      Jason.encode!(%{
        "pages" => [
          %{
            "page_id" => "solver_result",
            "page_type" => "custom",
            "backend" => %{"api_map" => %{"get" => "Scheduling.SolverRun.get"}},
            "status_keys" => ["record", "loading"]
          }
        ],
        "route_map" => [
          %{"path" => "/scheduling/solver_result", "page_id" => "solver_result"},
          %{"path" => "", "page_id" => "broken_page"}
        ]
      })
    )

    assert {:error, {:stitch_backend_page_contract_invalid, details}} =
             StitchBackend.contract("solver_result")

    assert Enum.any?(details["issues"], fn issue ->
             issue["code"] == "route_map_entry_invalid" and issue["severity"] == "error"
           end)
  end
end
