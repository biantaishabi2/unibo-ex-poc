defmodule UniboV4.Delivery.Workflows.ShipmentRouteSegment.RouteSegmentFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Delivery.ShipmentRouteSegment

  def steps do
    [:create, :confirm_shipment, :update_tracking, :record_cost, :update, :destroy]
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
        Ash.create(Ash.Changeset.for_create(ShipmentRouteSegment, :create, params), actor: actor)
      :confirm_shipment ->
        Ash.update(Ash.Changeset.for_update(record, :confirm_shipment, params), actor: actor)
      :update_tracking ->
        Ash.update(Ash.Changeset.for_update(record, :update_tracking, params), actor: actor)
      :record_cost ->
        Ash.update(Ash.Changeset.for_update(record, :record_cost, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
