defmodule UniboV4.Quality.Workflows.QualityAlert.AlertLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Quality.QualityAlert

  def steps do
    [:create, :confirm, :start_progress, :done]
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
        Ash.create(Ash.Changeset.for_create(QualityAlert, :create, params), actor: actor)
      :confirm ->
        Ash.update(Ash.Changeset.for_update(record, :confirm, params), actor: actor)
      :start_progress ->
        Ash.update(Ash.Changeset.for_update(record, :start_progress, params), actor: actor)
      :done ->
        Ash.update(Ash.Changeset.for_update(record, :done, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
