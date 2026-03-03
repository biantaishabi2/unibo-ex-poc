defmodule UniboV4.Subscriptions.Workflows.SubscriptionOrder.SubscriptionLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Subscriptions.SubscriptionOrder

  def steps do
    [:create, :action_confirm, :action_pause, :action_resume, :action_close, :action_renew]
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
        Ash.create(Ash.Changeset.for_create(SubscriptionOrder, :create, params), actor: actor)
      :action_confirm ->
        Ash.update(Ash.Changeset.for_update(record, :action_confirm, params), actor: actor)
      :action_pause ->
        Ash.update(Ash.Changeset.for_update(record, :action_pause, params), actor: actor)
      :action_resume ->
        Ash.update(Ash.Changeset.for_update(record, :action_resume, params), actor: actor)
      :action_close ->
        Ash.update(Ash.Changeset.for_update(record, :action_close, params), actor: actor)
      :action_renew ->
        Ash.create(Ash.Changeset.for_create(SubscriptionOrder, :action_renew, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
