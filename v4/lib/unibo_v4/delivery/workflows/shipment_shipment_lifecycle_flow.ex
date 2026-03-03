defmodule UniboV4.Delivery.Workflows.Shipment.ShipmentLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Delivery.Shipment

  def steps do
    [:create, :submit, :pick, :pack, :ship, :deliver, :cancel, :update, :destroy]
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
        Ash.create(Ash.Changeset.for_create(Shipment, :create, params), actor: actor)
      :submit ->
        Ash.update(Ash.Changeset.for_update(record, :submit, params), actor: actor)
      :pick ->
        Ash.update(Ash.Changeset.for_update(record, :pick, params), actor: actor)
      :pack ->
        Ash.update(Ash.Changeset.for_update(record, :pack, params), actor: actor)
      :ship ->
        Ash.update(Ash.Changeset.for_update(record, :ship, params), actor: actor)
      :deliver ->
        Ash.update(Ash.Changeset.for_update(record, :deliver, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
