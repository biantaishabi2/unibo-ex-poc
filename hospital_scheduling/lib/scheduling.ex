defmodule Scheduling do
  @moduledoc """
  排班领域的运行时桥接入口。

  这里承接 UniBO 模型里的 `invoke module: Scheduling.*` 钩子，
  把“浅状态流转 action”补成真正的业务命令。
  """

  alias HospitalScheduling.Scheduling, as: SchedulingDomain
  alias HospitalScheduling.Solver.Runner

  # 开始生成后，同步调用真实 solver，返回最新 period 记录。
  def trigger_solver_run(changeset, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, period ->
      case Runner.run(period.id, engine_type: "cp_sat") do
        {:ok, _result} -> reload_period(period.id)
        {:error, reason} -> {:error, format_reason(reason)}
      end
    end)
  end

  # 从周期直接发布时，校验 current_version 可发布，再委托版本发布。
  def publish_period_current_version(changeset, _context) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      period = changeset.data

      case period.current_version_id do
        nil ->
          Ash.Changeset.add_error(changeset, "当前周期没有可发布版本")

        version_id ->
          case Runner.pre_publish_check(version_id) do
            {:ok, %{publishable: true}} ->
              changeset

            {:ok, %{errors: errors}} ->
              Ash.Changeset.add_error(changeset, publish_error_message(errors))

            {:error, reason} ->
              Ash.Changeset.add_error(changeset, format_reason(reason))
          end
      end
    end)
    |> Ash.Changeset.after_action(fn _changeset, period ->
      with version_id when not is_nil(version_id) <- period.current_version_id,
           {:ok, version} <-
             Ash.get(SchedulingDomain.ScheduleVersion, version_id, authorize?: false),
           {:ok, _published_version} <-
             Ash.update(version, %{}, action: :publish_version, authorize?: false) do
        reload_period(period.id)
      else
        nil -> {:error, "当前周期没有可发布版本"}
        {:error, reason} -> {:error, format_reason(reason)}
      end
    end)
  end

  # 发布版本时，同步 period 的 published_version/state。
  def publish_schedule_version(changeset, _context) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      version = changeset.data

      case Runner.pre_publish_check(version.id) do
        {:ok, %{publishable: true}} ->
          changeset

        {:ok, %{errors: errors}} ->
          Ash.Changeset.add_error(changeset, publish_error_message(errors))

        {:error, reason} ->
          Ash.Changeset.add_error(changeset, format_reason(reason))
      end
    end)
    |> Ash.Changeset.after_action(fn _changeset, version ->
      with {:ok, period} <-
             Ash.get(SchedulingDomain.SchedulingPeriod, version.period_id, authorize?: false),
           period_changeset =
             period
             |> Ash.Changeset.for_update(:update, %{})
             |> Ash.Changeset.force_change_attribute(:published_version_id, version.id)
             |> Ash.Changeset.force_change_attribute(:state, :published),
           {:ok, _updated_period} <- Ash.update(period_changeset, authorize?: false) do
        {:ok, version}
      else
        {:error, reason} -> {:error, format_reason(reason)}
      end
    end)
  end

  defp reload_period(period_id) do
    Ash.get(SchedulingDomain.SchedulingPeriod, period_id, authorize?: false)
  end

  defp publish_error_message([]), do: "当前版本未通过发布前校验"

  defp publish_error_message(errors) do
    errors
    |> Enum.map(fn error ->
      cond do
        is_binary(error) -> error
        is_map(error) -> Map.get(error, :message) || Map.get(error, "message") || inspect(error)
        true -> inspect(error)
      end
    end)
    |> Enum.join("；")
  end

  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason), do: inspect(reason)
end
