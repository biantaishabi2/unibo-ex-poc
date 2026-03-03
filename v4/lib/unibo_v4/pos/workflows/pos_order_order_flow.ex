defmodule UniboV4.POS.Workflows.PosOrder.OrderFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.POS.PosOrder

  def steps do
    [:create, :pay, :done, :invoice, :refund, :cancel, :destroy]
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
        Ash.create(Ash.Changeset.for_create(PosOrder, :create, params), actor: actor)
      :pay ->
        Ash.update(Ash.Changeset.for_update(record, :pay, params), actor: actor)
      :done ->
        Ash.update(Ash.Changeset.for_update(record, :done, params), actor: actor)
      :invoice ->
        Ash.update(Ash.Changeset.for_update(record, :invoice, params), actor: actor)
      :refund ->
        Ash.create(Ash.Changeset.for_create(PosOrder, :refund, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
