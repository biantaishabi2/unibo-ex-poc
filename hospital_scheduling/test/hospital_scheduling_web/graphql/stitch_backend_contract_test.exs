defmodule HospitalSchedulingWeb.Graphql.StitchBackendContractTest do
  use ExUnit.Case, async: false

  alias HospitalSchedulingWeb.Graphql.RuntimeConfig
  alias HospitalSchedulingWeb.Graphql.StitchBackend

  @app :hospital_scheduling
  @config_key HospitalSchedulingWeb.Graphql.RuntimeConfig

  setup do
    tmp_dir = Path.join(System.tmp_dir!(), "hospital_scheduling_stitch_contract_test")
    File.mkdir_p!(tmp_dir)

    frontend_manifest_path = Path.join(tmp_dir, "frontend_manifest.v1.json")

    File.write!(
      frontend_manifest_path,
      Jason.encode!(%{
        "pages" => [
          %{
            "page_id" => "solver_result",
            "page_kind" => "custom",
            "status_keys" => ["period", "run", "violations"],
            "state_schema" => %{"defaults" => %{}},
            "api_map" => %{"get" => "Scheduling.SolverRun.get"}
          },
          %{
            "page_id" => "publish_preview",
            "page_kind" => "custom",
            "status_keys" => ["version", "changes"],
            "state_schema" => %{"defaults" => %{}},
            "api_map" => %{
              "get" => "Scheduling.ScheduleVersion.get",
              "action_publish" => "Scheduling.ScheduleVersion.publish_version"
            }
          }
        ],
        "route_map" => []
      })
    )

    previous = Application.get_env(@app, @config_key, [])

    Application.put_env(
      @app,
      @config_key,
      Keyword.put(previous, :frontend_manifest, frontend_manifest_path)
    )

    on_exit(fn ->
      Application.put_env(@app, @config_key, previous)
      File.rm_rf(tmp_dir)
    end)

    :ok
  end

  test "frontend manifest 可被运行时读取" do
    manifest = RuntimeConfig.frontend_manifest()

    assert is_list(manifest["pages"])
    assert Enum.any?(manifest["pages"], &(&1["page_id"] == "solver_result"))
  end

  test "complex page contract 暴露 api backend 合同" do
    assert {:ok, contract} = StitchBackend.contract("publish_preview")

    assert get_in(contract, ["backend", "mode"]) == "api"
    assert get_in(contract, ["backend", "load", "event"]) == "__load__"
    assert get_in(contract, ["backend", "api_map", "get"]) == "Scheduling.ScheduleVersion.get"

    assert get_in(contract, ["backend", "api_map", "action_publish"]) ==
             "Scheduling.ScheduleVersion.publish_version"
  end
end
