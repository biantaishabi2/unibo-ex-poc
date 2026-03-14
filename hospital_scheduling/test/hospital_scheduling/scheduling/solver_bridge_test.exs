defmodule HospitalScheduling.Scheduling.SolverBridgeTest do
  use ExUnit.Case, async: false

  alias HospitalScheduling.Scheduling.SolverBridge

  test "cp_sat bridge solves blank snapshot fixture" do
    input_snapshot =
      solver_fixture_path("blank_snapshot.json")
      |> File.read!()

    output_snapshot = SolverBridge.solve_snapshot!(input_snapshot)

    assert output_snapshot["summary"]["engine_type"] == "cp_sat"
    assert output_snapshot["summary"]["covered_requirement_count"] == 2
    assert length(output_snapshot["assignments"]) == 2
  end

  test "cp_sat bridge returns structured violations for infeasible fixture" do
    input_snapshot =
      solver_fixture_path("lead_gap_snapshot.json")
      |> File.read!()

    output_snapshot = SolverBridge.solve_snapshot!(input_snapshot)

    assert output_snapshot["status"] == "infeasible"

    assert Enum.any?(output_snapshot["violations"], fn violation ->
             violation["rule_code"] == "lead_coverage" and violation["severity"] == "error"
           end)
  end

  defp solver_fixture_path(filename) do
    Path.expand(
      "../../../../solver_rust/hospital_scheduling_solver/fixtures/#{filename}",
      __DIR__
    )
  end
end
