defmodule UniboV4.Maintenance.Workflows.Vehicle.VehicleLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Maintenance.Vehicle

  def steps do
    [:create, :update, :change_driver, :set_future_driver, :change_state, :deactivate, :set_odometer]
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
        Ash.create(Ash.Changeset.for_create(Vehicle, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :change_driver ->
        Ash.update(Ash.Changeset.for_update(record, :change_driver, params), actor: actor)
      :set_future_driver ->
        Ash.update(Ash.Changeset.for_update(record, :set_future_driver, params), actor: actor)
      :change_state ->
        Ash.update(Ash.Changeset.for_update(record, :change_state, params), actor: actor)
      :deactivate ->
        Ash.update(Ash.Changeset.for_update(record, :deactivate, params), actor: actor)
      :set_odometer ->
        Ash.update(Ash.Changeset.for_update(record, :set_odometer, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
