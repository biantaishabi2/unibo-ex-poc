defmodule HospitalScheduling.Repo.Migrations.UpdateSolverRunEngineTypeDefaultToCpSat do
  use Ecto.Migration

  def change do
    alter table(:scheduling_solver_runs) do
      modify :engine_type, :text, default: "cp_sat", null: false
    end
  end
end
