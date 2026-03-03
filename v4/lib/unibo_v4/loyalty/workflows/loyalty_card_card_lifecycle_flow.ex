defmodule UniboV4.Loyalty.Workflows.LoyaltyCard.CardLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Loyalty.LoyaltyCard

  def steps do
    [:create, :earn_points, :redeem_points, :freeze, :unfreeze, :expire_card]
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
        Ash.create(Ash.Changeset.for_create(LoyaltyCard, :create, params), actor: actor)
      :earn_points ->
        Ash.update(Ash.Changeset.for_update(record, :earn_points, params), actor: actor)
      :redeem_points ->
        Ash.update(Ash.Changeset.for_update(record, :redeem_points, params), actor: actor)
      :freeze ->
        Ash.update(Ash.Changeset.for_update(record, :freeze, params), actor: actor)
      :unfreeze ->
        Ash.update(Ash.Changeset.for_update(record, :unfreeze, params), actor: actor)
      :expire_card ->
        Ash.update(Ash.Changeset.for_update(record, :expire_card, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
