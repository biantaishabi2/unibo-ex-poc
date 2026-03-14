defmodule HospitalScheduling.Scheduling.SolverAdapterTest do
  use ExUnit.Case, async: true

  alias HospitalScheduling.Scheduling.SolverAdapter

  test "run_snapshot decodes solver output via injected executor" do
    input_snapshot =
      File.read!(
        Path.expand(
          "../../../../solver_rust/hospital_scheduling_solver/fixtures/blank_snapshot.json",
          __DIR__
        )
      )

    executor = fn _payload, _opts ->
      {:ok,
       Jason.encode!(%{
         "status" => "completed",
         "summary" => %{
           "phase" => "cp_sat_emit_result",
           "requirement_count" => 1,
           "covered_requirement_count" => 1,
           "assignment_count" => 1,
           "error_count" => 0,
           "warning_count" => 0,
           "score" => 100,
           "seed" => 42,
           "duration_ms" => 12,
           "engine_type" => "cp_sat"
         },
         "assignments" => [],
         "coverage" => [],
         "violations" => []
       })}
    end

    assert {:ok, %{decoded: decoded, raw: raw}} =
             SolverAdapter.run_snapshot(input_snapshot, executor: executor)

    assert decoded["summary"]["engine_type"] == "cp_sat"
    assert is_binary(raw)
  end

  test "run_snapshot returns invalid_json when input snapshot is malformed" do
    assert {:error, {:invalid_json, _error}} =
             SolverAdapter.run_snapshot("{bad-json", executor: fn _, _ -> {:ok, "{}"} end)
  end
end
