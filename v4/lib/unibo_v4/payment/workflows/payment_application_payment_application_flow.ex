defmodule UniboV4.Payment.Workflows.PaymentApplication.PaymentApplicationFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Payment.PaymentApplication

  def steps do
    [:create, :apply_to_invoice, :apply_to_account, :update, :destroy]
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
        Ash.create(Ash.Changeset.for_create(PaymentApplication, :create, params), actor: actor)
      :apply_to_invoice ->
        Ash.create(Ash.Changeset.for_create(PaymentApplication, :apply_to_invoice, params), actor: actor)
      :apply_to_account ->
        Ash.create(Ash.Changeset.for_create(PaymentApplication, :apply_to_account, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
