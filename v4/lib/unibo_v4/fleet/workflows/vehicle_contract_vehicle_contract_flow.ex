defmodule UniboV4.Fleet.Workflows.VehicleContract.VehicleContractFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Fleet.VehicleContract

  def steps do
    [:create, :activate, :renew, :terminate]
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
        Ash.create(Ash.Changeset.for_create(VehicleContract, :create, params), actor: actor)
      :activate ->
        Ash.update(Ash.Changeset.for_update(record, :activate, params), actor: actor)
      :renew ->
        Ash.update(Ash.Changeset.for_update(record, :renew, params), actor: actor)
      :terminate ->
        Ash.update(Ash.Changeset.for_update(record, :terminate, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
