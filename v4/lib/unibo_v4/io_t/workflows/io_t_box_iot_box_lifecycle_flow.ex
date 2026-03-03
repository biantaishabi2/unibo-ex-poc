defmodule UniboV4.IoT.Workflows.IoTBox.IotBoxLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.IoT.IoTBox

  def steps do
    [:create, :register_box, :heartbeat, :update]
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
        Ash.create(Ash.Changeset.for_create(IoTBox, :create, params), actor: actor)
      :register_box ->
        Ash.update(Ash.Changeset.for_update(record, :register_box, params), actor: actor)
      :heartbeat ->
        Ash.update(Ash.Changeset.for_update(record, :heartbeat, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
