defmodule UniboV4.Manufacturing.Workflows.ManufacturingOrder.ManufacturingOrderFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Manufacturing.ManufacturingOrder

  def steps do
    [:create, :confirm, :start, :produce, :mark_done, :complete, :split_production, :cancel]
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
        Ash.create(Ash.Changeset.for_create(ManufacturingOrder, :create, params), actor: actor)
      :confirm ->
        Ash.update(Ash.Changeset.for_update(record, :confirm, params), actor: actor)
      :start ->
        Ash.update(Ash.Changeset.for_update(record, :start, params), actor: actor)
      :produce ->
        Ash.update(Ash.Changeset.for_update(record, :produce, params), actor: actor)
      :mark_done ->
        Ash.update(Ash.Changeset.for_update(record, :mark_done, params), actor: actor)
      :complete ->
        Ash.update(Ash.Changeset.for_update(record, :complete, params), actor: actor)
      :split_production ->
        Ash.update(Ash.Changeset.for_update(record, :split_production, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
