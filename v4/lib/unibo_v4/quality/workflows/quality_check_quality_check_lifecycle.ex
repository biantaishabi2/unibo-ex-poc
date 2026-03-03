defmodule UniboV4.Quality.Workflows.QualityCheck.QualityCheckLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Quality.QualityCheck

  def steps do
    [:create, :do_pass, :do_fail]
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
        Ash.create(Ash.Changeset.for_create(QualityCheck, :create, params), actor: actor)
      :do_pass ->
        Ash.update(Ash.Changeset.for_update(record, :do_pass, params), actor: actor)
      :do_fail ->
        Ash.update(Ash.Changeset.for_update(record, :do_fail, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
