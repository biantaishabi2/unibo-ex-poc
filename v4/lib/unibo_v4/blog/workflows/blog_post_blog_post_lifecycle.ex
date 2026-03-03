defmodule UniboV4.Blog.Workflows.BlogPost.BlogPostLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Blog.BlogPost

  def steps do
    [:create, :update, :publish, :unpublish, :archive, :unarchive]
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
        Ash.create(Ash.Changeset.for_create(BlogPost, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :publish ->
        Ash.update(Ash.Changeset.for_update(record, :publish, params), actor: actor)
      :unpublish ->
        Ash.update(Ash.Changeset.for_update(record, :unpublish, params), actor: actor)
      :archive ->
        Ash.update(Ash.Changeset.for_update(record, :archive, params), actor: actor)
      :unarchive ->
        Ash.update(Ash.Changeset.for_update(record, :unarchive, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
