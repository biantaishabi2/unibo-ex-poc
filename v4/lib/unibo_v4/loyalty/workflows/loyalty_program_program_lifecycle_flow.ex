defmodule UniboV4.Loyalty.Workflows.LoyaltyProgram.ProgramLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Loyalty.LoyaltyProgram

  def steps do
    [:create, :update, :activate, :pause, :expire]
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
        Ash.create(Ash.Changeset.for_create(LoyaltyProgram, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :activate ->
        Ash.update(Ash.Changeset.for_update(record, :activate, params), actor: actor)
      :pause ->
        Ash.update(Ash.Changeset.for_update(record, :pause, params), actor: actor)
      :expire ->
        Ash.update(Ash.Changeset.for_update(record, :expire, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
