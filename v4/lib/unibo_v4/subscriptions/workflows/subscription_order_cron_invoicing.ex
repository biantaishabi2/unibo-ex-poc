defmodule UniboV4.Subscriptions.Workflows.SubscriptionOrder.CronInvoicingWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  def steps do
    [:evaluate_invoicing_due, :generate_invoice]
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
      :evaluate_invoicing_due ->
        Ash.update(Ash.Changeset.for_update(record, :evaluate_invoicing_due, params), actor: actor)
      :generate_invoice ->
        Ash.update(Ash.Changeset.for_update(record, :generate_invoice, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
