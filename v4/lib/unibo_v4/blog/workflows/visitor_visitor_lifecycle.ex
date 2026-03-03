defmodule UniboV4.Blog.Workflows.Visitor.VisitorLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Blog.Visitor

  def steps do
    [:upsert, :track_visit, :merge, :cleanup]
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
      :upsert ->
        Ash.create(Ash.Changeset.for_create(Visitor, :upsert, params), actor: actor)
      :track_visit ->
        Ash.update(Ash.Changeset.for_update(record, :track_visit, params), actor: actor)
      :merge ->
        Ash.update(Ash.Changeset.for_update(record, :merge, params), actor: actor)
      :cleanup ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :cleanup, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
