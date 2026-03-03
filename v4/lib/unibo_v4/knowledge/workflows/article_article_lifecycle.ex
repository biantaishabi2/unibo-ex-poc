defmodule UniboV4.Knowledge.Workflows.Article.ArticleLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Knowledge.Article

  def steps do
    [:create, :update, :action_publish, :action_unpublish, :action_archive, :action_restore_state, :action_trash, :action_restore_trash, :action_lock, :action_unlock, :action_move, :action_copy]
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
        Ash.create(Ash.Changeset.for_create(Article, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :action_publish ->
        Ash.update(Ash.Changeset.for_update(record, :action_publish, params), actor: actor)
      :action_unpublish ->
        Ash.update(Ash.Changeset.for_update(record, :action_unpublish, params), actor: actor)
      :action_archive ->
        Ash.update(Ash.Changeset.for_update(record, :action_archive, params), actor: actor)
      :action_restore_state ->
        Ash.update(Ash.Changeset.for_update(record, :action_restore_state, params), actor: actor)
      :action_trash ->
        Ash.update(Ash.Changeset.for_update(record, :action_trash, params), actor: actor)
      :action_restore_trash ->
        Ash.update(Ash.Changeset.for_update(record, :action_restore_trash, params), actor: actor)
      :action_lock ->
        Ash.update(Ash.Changeset.for_update(record, :action_lock, params), actor: actor)
      :action_unlock ->
        Ash.update(Ash.Changeset.for_update(record, :action_unlock, params), actor: actor)
      :action_move ->
        Ash.update(Ash.Changeset.for_update(record, :action_move, params), actor: actor)
      :action_copy ->
        Ash.create(Ash.Changeset.for_create(Article, :action_copy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
