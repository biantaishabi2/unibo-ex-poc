defmodule UniboV4.Sales.Workflows.SalesOrder.PricingChainWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  def steps do
    [:select_product_price, :compute_line_subtotal, :compute_tax, :aggregate_totals]
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
      :select_product_price ->
        Ash.update(Ash.Changeset.for_update(record, :select_product_price, params), actor: actor)
      :compute_line_subtotal ->
        Ash.update(Ash.Changeset.for_update(record, :compute_line_subtotal, params), actor: actor)
      :compute_tax ->
        Ash.update(Ash.Changeset.for_update(record, :compute_tax, params), actor: actor)
      :aggregate_totals ->
        Ash.update(Ash.Changeset.for_update(record, :aggregate_totals, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
