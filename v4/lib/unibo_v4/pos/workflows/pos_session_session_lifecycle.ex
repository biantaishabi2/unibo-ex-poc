defmodule UniboV4.POS.Workflows.PosSession.SessionLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.POS.PosSession

  def steps do
    [:create, :open, :start_close, :close]
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
        Ash.create(Ash.Changeset.for_create(PosSession, :create, params), actor: actor)
      :open ->
        Ash.update(Ash.Changeset.for_update(record, :open, params), actor: actor)
      :start_close ->
        Ash.update(Ash.Changeset.for_update(record, :start_close, params), actor: actor)
      :close ->
        Ash.update(Ash.Changeset.for_update(record, :close, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
