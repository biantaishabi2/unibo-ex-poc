defmodule UniboV4.Forum.Workflows.Post.PostLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Forum.Post

  def steps do
    [:create, :validate, :update, :close, :reopen, :flag, :mark_offensive, :accept_answer, :unaccept_answer, :toggle_favourite, :destroy]
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
        Ash.create(Ash.Changeset.for_create(Post, :create, params), actor: actor)
      :validate ->
        Ash.update(Ash.Changeset.for_update(record, :validate, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :close ->
        Ash.update(Ash.Changeset.for_update(record, :close, params), actor: actor)
      :reopen ->
        Ash.update(Ash.Changeset.for_update(record, :reopen, params), actor: actor)
      :flag ->
        Ash.update(Ash.Changeset.for_update(record, :flag, params), actor: actor)
      :mark_offensive ->
        Ash.update(Ash.Changeset.for_update(record, :mark_offensive, params), actor: actor)
      :accept_answer ->
        Ash.update(Ash.Changeset.for_update(record, :accept_answer, params), actor: actor)
      :unaccept_answer ->
        Ash.update(Ash.Changeset.for_update(record, :unaccept_answer, params), actor: actor)
      :toggle_favourite ->
        Ash.update(Ash.Changeset.for_update(record, :toggle_favourite, params), actor: actor)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
