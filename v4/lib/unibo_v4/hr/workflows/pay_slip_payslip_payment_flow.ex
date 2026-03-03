defmodule UniboV4.HR.Workflows.PaySlip.PayslipPaymentFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.HR.PaySlip

  def steps do
    [:create, :compute_sheet, :action_payslip_done, :action_payslip_paid]
  end

  def run(record, opts \\ []) do
    Enum.reduce_while(steps(), {:ok, record}, fn step, {:ok, current} ->
      case apply_step(current, step, opts) do
        {:ok, next_record} -> {:cont, {:ok, next_record}}
        {:error, reason} -> {:halt, {:error, %{step: step, reason: reason}}}
      end
    end)
  end

  defp apply_step(record, step, opts) do
    actor = Keyword.get(opts, :actor)
    params_by_step = Keyword.get(opts, :params, %{})
    params = Map.get(params_by_step, step, %{})

    case step do
      :create ->
        Ash.create(Ash.Changeset.for_create(PaySlip, :create, params), actor: actor)
      :compute_sheet ->
        Ash.update(Ash.Changeset.for_update(record, :compute_sheet, params), actor: actor)
      :action_payslip_done ->
        Ash.update(Ash.Changeset.for_update(record, :action_payslip_done, params), actor: actor)
      :action_payslip_paid ->
        Ash.update(Ash.Changeset.for_update(record, :action_payslip_paid, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
