defmodule UniboV4.Marketing.Workflows.SocialPost.SocialPostLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Marketing.SocialPost

  def steps do
    [:create, :update, :publish_now, :schedule, :sync_stats]
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
        Ash.create(Ash.Changeset.for_create(SocialPost, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :publish_now ->
        Ash.update(Ash.Changeset.for_update(record, :publish_now, params), actor: actor)
      :schedule ->
        Ash.update(Ash.Changeset.for_update(record, :schedule, params), actor: actor)
      :sync_stats ->
        Ash.update(Ash.Changeset.for_update(record, :sync_stats, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
