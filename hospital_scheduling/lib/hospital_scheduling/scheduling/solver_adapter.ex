defmodule HospitalScheduling.Scheduling.SolverAdapter do
  @moduledoc """
  调用 Rust CP-SAT solver，并负责把 SolverRun 生命周期推进到完成态。
  """

  alias HospitalScheduling.Scheduling
  alias HospitalScheduling.Scheduling.ConstraintViolation
  alias HospitalScheduling.Scheduling.ScheduleVersion
  alias HospitalScheduling.Scheduling.ShiftAssignment
  alias HospitalScheduling.Scheduling.SolverRun

  @type executor :: (binary(), keyword() -> {:ok, binary()} | {:error, term()})

  @spec run_snapshot(binary(), keyword()) ::
          {:ok, %{decoded: map(), raw: binary()}} | {:error, term()}
  def run_snapshot(input_snapshot, opts \\ []) when is_binary(input_snapshot) do
    executor = Keyword.get(opts, :executor, &default_executor/2)

    with {:ok, _decoded_input} <- Jason.decode(input_snapshot),
         {:ok, raw_output} <- executor.(input_snapshot, opts),
         {:ok, decoded_output} <- Jason.decode(raw_output) do
      {:ok, %{decoded: decoded_output, raw: raw_output}}
    else
      {:error, %Jason.DecodeError{} = error} -> {:error, {:invalid_json, error}}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec run_solver_run(SolverRun.t(), keyword()) ::
          {:ok, SolverRun.t()} | {:error, term()}
  def run_solver_run(%SolverRun{} = run, opts \\ []) do
    ash_opts = Keyword.get(opts, :ash_opts, domain: Scheduling)

    with {:ok, running_run} <-
           Ash.update(Ash.Changeset.for_update(run, :start_run, %{}), ash_opts),
         {:ok, %{decoded: output_snapshot, raw: raw_output}} <-
           run_snapshot(running_run.input_snapshot, opts),
         {:ok, completed_run} <- complete_run(running_run, output_snapshot, raw_output, ash_opts) do
      {:ok, completed_run}
    else
      {:error, reason} -> mark_error(run, reason, opts)
    end
  end

  defp complete_run(run, output_snapshot, raw_output, ash_opts) do
    summary = Map.get(output_snapshot, "summary", %{})

    with {:ok, _version} <- persist_version_chain(run, output_snapshot, ash_opts) do
      params = %{
        score: summary["score"],
        hard_violation_count: summary["error_count"] || 0,
        warning_count: summary["warning_count"] || 0,
        output_snapshot: raw_output,
        error_message: completion_error_message(output_snapshot)
      }

      if (summary["error_count"] || 0) == 0 do
        Ash.update(
          Ash.Changeset.for_update(run, :complete_feasible, Map.delete(params, :error_message)),
          ash_opts
        )
      else
        Ash.update(Ash.Changeset.for_update(run, :complete_infeasible, params), ash_opts)
      end
    end
  end

  defp persist_version_chain(run, output_snapshot, ash_opts) do
    with {:ok, version} <- create_schedule_version(run, output_snapshot, ash_opts),
         :ok <- persist_assignments(version, run, output_snapshot, ash_opts),
         :ok <- persist_violations(version, run, output_snapshot, ash_opts) do
      {:ok, version}
    end
  end

  defp create_schedule_version(run, output_snapshot, ash_opts) do
    summary = Map.get(output_snapshot, "summary", %{})

    params = %{
      version_no: next_version_no(run.period_id, ash_opts),
      status: :working,
      origin_type: :solver,
      change_summary: "solver #{summary["engine_type"] || "unknown"}"
    }

    ScheduleVersion
    |> Ash.Changeset.for_create(:create, params, %{
      period_id: run.period_id,
      based_on_run_id: run.id
    })
    |> Ash.create(ash_opts)
  end

  defp persist_assignments(version, run, output_snapshot, ash_opts) do
    output_snapshot
    |> Map.get("assignments", [])
    |> Enum.reduce_while(:ok, fn assignment, :ok ->
      params = %{
        starts_at: assignment["starts_at"],
        ends_at: assignment["ends_at"],
        source: parse_source(assignment["source"]),
        is_locked: assignment["locked"] || false
      }

      result =
        ShiftAssignment
        |> Ash.Changeset.for_create(:create, params, %{
          period_id: run.period_id,
          requirement_id: assignment["requirement_id"],
          version_id: version.id,
          employee_id: assignment["employee_id"]
        })
        |> Ash.create(ash_opts)

      case result do
        {:ok, _assignment} -> {:cont, :ok}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp persist_violations(version, run, output_snapshot, ash_opts) do
    output_snapshot
    |> Map.get("violations", [])
    |> Enum.reduce_while(:ok, fn violation, :ok ->
      params = %{
        rule_code: violation["rule_code"],
        severity: parse_severity(violation["severity"]),
        message: violation["message"],
        details_json: Jason.encode!(violation["details"] || %{})
      }

      args =
        %{period_id: run.period_id, version_id: version.id}
        |> maybe_put(:requirement_id, violation["requirement_id"])

      result =
        ConstraintViolation
        |> Ash.Changeset.for_create(:create, params, args)
        |> Ash.create(ash_opts)

      case result do
        {:ok, _violation} -> {:cont, :ok}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp next_version_no(period_id, ash_opts) do
    ScheduleVersion
    |> Ash.Query.for_read(:read)
    |> Ash.read!(ash_opts)
    |> Enum.filter(&(&1.period_id == period_id))
    |> Enum.map(& &1.version_no)
    |> Enum.max(fn -> 0 end)
    |> Kernel.+(1)
  end

  defp completion_error_message(output_snapshot) do
    output_snapshot
    |> Map.get("violations", [])
    |> Enum.filter(&(Map.get(&1, "severity") == "error"))
    |> Enum.map(&Map.get(&1, "message"))
    |> Enum.uniq()
    |> Enum.join("; ")
  end

  defp mark_error(%SolverRun{} = run, reason, opts) do
    ash_opts = Keyword.get(opts, :ash_opts, domain: Scheduling)
    params = %{error_message: format_error(reason)}

    case Ash.update(Ash.Changeset.for_update(run, :mark_error, params), ash_opts) do
      {:ok, errored_run} -> {:ok, errored_run}
      {:error, update_error} -> {:error, update_error}
    end
  end

  defp format_error({:invalid_json, error}), do: Exception.message(error)
  defp format_error({:solver_command_failed, message}), do: message
  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(reason), do: inspect(reason)

  defp parse_source("manual"), do: :manual
  defp parse_source("swapped"), do: :swapped
  defp parse_source("copied"), do: :copied
  defp parse_source(_), do: :auto

  defp parse_severity("warning"), do: :warning
  defp parse_severity(_), do: :error

  defp default_executor(input_snapshot, _opts) do
    script_path = solver_script_path()

    with {:ok, temp_path} <- write_temp_snapshot(input_snapshot),
         result <- System.cmd(script_path, [temp_path], stderr_to_stdout: true) do
      File.rm(temp_path)

      case result do
        {output, 0} ->
          {:ok, String.trim(output)}

        {output, status} ->
          {:error,
           {:solver_command_failed, "solver exited with status #{status}: #{String.trim(output)}"}}
      end
    end
  end

  defp solver_script_path do
    Path.expand(
      "../../../../solver_rust/hospital_scheduling_solver/scripts/run_cp_sat_solver.sh",
      __DIR__
    )
  end

  defp write_temp_snapshot(input_snapshot) do
    temp_dir = System.tmp_dir!()

    temp_path =
      Path.join(
        temp_dir,
        "hospital_scheduling_solver_input_#{System.unique_integer([:positive])}.json"
      )

    case File.write(temp_path, input_snapshot) do
      :ok ->
        {:ok, temp_path}

      {:error, reason} ->
        {:error, {:solver_command_failed, "failed to write temp snapshot: #{inspect(reason)}"}}
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
