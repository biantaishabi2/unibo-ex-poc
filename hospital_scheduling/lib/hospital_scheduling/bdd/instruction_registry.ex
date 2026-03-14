defmodule HospitalScheduling.BDD.InstructionRegistry do
  @moduledoc false

  @type version :: :v1 | :v2
  @type instruction_spec :: map()

  @spec all(version()) :: [instruction_spec()]
  def all(version \\ :v1)
  def all(:v1), do: specs()
  def all(:v2), do: specs()

  @spec fetch(atom(), version()) :: {:ok, instruction_spec()} | :error
  def fetch(name, version \\ :v1) when is_atom(name) do
    case Enum.find(all(version), &(&1.name == name)) do
      nil -> :error
      spec -> {:ok, spec}
    end
  end

  @spec fetch!(atom(), version()) :: instruction_spec()
  def fetch!(name, version \\ :v1) when is_atom(name) do
    case fetch(name, version) do
      {:ok, spec} -> spec
      :error -> raise KeyError, "unknown instruction: #{inspect(name)}"
    end
  end

  @spec supported_versions(atom()) :: [version()]
  def supported_versions(name) when is_atom(name) do
    [:v1, :v2]
    |> Enum.filter(fn version -> match?({:ok, _}, fetch(name, version)) end)
  end

  defp specs do
    [
      %{
        name: :create_temp_dir,
        kind: :given,
        args: %{key: %{type: :string, required?: true, allowed: nil}},
        outputs: %{path: :string},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :test_runtime,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :create_temp_file,
        kind: :given,
        args: %{
          dir: %{type: :string, required?: true, allowed: nil},
          filename: %{type: :string, required?: true, allowed: nil},
          content: %{type: :string, required?: false, allowed: nil}
        },
        outputs: %{path: :string},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :test_runtime,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :given_seed_context,
        kind: :given,
        args: %{
          id: %{type: :string, required?: true, allowed: nil},
          module: %{type: :string, required?: true, allowed: nil}
        },
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :noop,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :test_runtime,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :when_execute_seed_contract,
        kind: :when,
        args: %{module: %{type: :string, required?: true, allowed: nil}},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :assert_noop,
        kind: :then,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :test_runtime,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :then_seed_contract_should_hold,
        kind: :then,
        args: %{module: %{type: :string, required?: true, allowed: nil}},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: :C
      },
      %{
        name: :unibo_scheduling_constraint_violation_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_constraint_violation_action_destroy,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_constraint_violation_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_coverage_requirement_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_coverage_requirement_action_destroy,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_coverage_requirement_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_coverage_requirement_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_department_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_employee_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_medical_staff_profile_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_medical_staff_profile_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_medical_staff_profile_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_schedule_version_action_archive_version,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_schedule_version_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_schedule_version_action_publish_version,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_schedule_version_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_schedule_version_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_constraint_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_constraint_action_destroy,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_constraint_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_constraint_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_destroy,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_mark_adjusted,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_mark_generated,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_publish,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_start_generating,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_scheduling_period_workflow_scheduling_period_lifecycle,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_assignment_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_assignment_action_destroy,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_assignment_action_lock,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_assignment_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_assignment_action_unlock,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_assignment_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_preference_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_preference_action_destroy,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_preference_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_preference_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_type_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_type_action_destroy,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_type_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_shift_type_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_complete_feasible,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_complete_infeasible,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_create,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_mark_completed,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_mark_error,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_mark_timeout,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_read,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_start_run,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_action_update,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      },
      %{
        name: :unibo_scheduling_solver_run_workflow_solver_run_lifecycle,
        kind: :when,
        args: %{},
        outputs: %{},
        rules: [],
        scopes: [:integration, :e2e],
        boundary: :service,
        async?: false,
        eventually?: false,
        assert_class: nil
      }
    ]
  end
end
