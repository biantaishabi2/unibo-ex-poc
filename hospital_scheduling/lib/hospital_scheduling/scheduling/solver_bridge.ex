defmodule HospitalScheduling.Scheduling.SolverBridge do
  @moduledoc """
  负责把冻结后的 JSON snapshot 交给 Rust solver，再把 output_snapshot 解回 Elixir map。
  """

  @default_ortools_prefix Path.expand("~/.local/opt/ortools/v9.15.6755")

  @spec solve_snapshot(binary(), keyword()) :: {:ok, map()} | {:error, term()}
  def solve_snapshot(input_snapshot_json, opts \\ []) when is_binary(input_snapshot_json) do
    with_temp_snapshot(input_snapshot_json, fn snapshot_path ->
      command =
        [
          "cargo run --quiet",
          "--manifest-path #{shell_escape(solver_manifest_path())}",
          "--features cp_sat_backend",
          "--bin solve_snapshot",
          "< #{shell_escape(snapshot_path)}"
        ]
        |> Enum.join(" ")

      case System.cmd("bash", ["-lc", command],
             stderr_to_stdout: true,
             cd: workspace_root(),
             env: solver_env(opts)
           ) do
        {output, 0} ->
          Jason.decode(output)

        {output, exit_code} ->
          {:error, {:solver_command_failed, exit_code, String.trim(output)}}
      end
    end)
  end

  @spec solve_snapshot!(binary(), keyword()) :: map()
  def solve_snapshot!(input_snapshot_json, opts \\ []) when is_binary(input_snapshot_json) do
    case solve_snapshot(input_snapshot_json, opts) do
      {:ok, output_snapshot} -> output_snapshot
      {:error, reason} -> raise ArgumentError, "solver bridge failed: #{inspect(reason)}"
    end
  end

  defp workspace_root do
    Path.expand("../../../..", __DIR__)
  end

  defp solver_manifest_path do
    Path.join([workspace_root(), "solver_rust", "hospital_scheduling_solver", "Cargo.toml"])
  end

  defp solver_env(opts) do
    ortools_prefix =
      opts[:ortools_prefix] ||
        System.get_env("ORTOOLS_PREFIX") ||
        @default_ortools_prefix

    ortools_lib = Path.join(ortools_prefix, "lib")

    %{
      "ORTOOLS_PREFIX" => ortools_prefix,
      "LD_LIBRARY_PATH" => prepend_env("LD_LIBRARY_PATH", ortools_lib),
      "LIBRARY_PATH" => prepend_env("LIBRARY_PATH", ortools_lib),
      "CXXFLAGS" => System.get_env("CXXFLAGS") || "-DOR_PROTO_DLL=",
      "RUSTFLAGS" =>
        System.get_env("RUSTFLAGS") ||
          "-L native=#{ortools_lib} -Clink-arg=-lprotobuf"
    }
  end

  defp prepend_env(name, value) do
    case System.get_env(name) do
      nil -> value
      "" -> value
      current -> value <> ":" <> current
    end
  end

  defp with_temp_snapshot(input_snapshot_json, fun) do
    snapshot_path =
      Path.join(
        System.tmp_dir!(),
        "hospital_scheduling_solver_#{System.unique_integer([:positive])}.json"
      )

    File.write!(snapshot_path, input_snapshot_json)

    try do
      fun.(snapshot_path)
    after
      File.rm(snapshot_path)
    end
  end

  defp shell_escape(path) do
    "'" <> String.replace(path, "'", "'\"'\"'") <> "'"
  end
end
