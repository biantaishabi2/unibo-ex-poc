defmodule UniboV4.PLM.Workflows.BomRevision.BomActivationSyncWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  def steps do
    [:evaluate_activation, :sync_draft_mo]
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
      :evaluate_activation ->
        Ash.update(Ash.Changeset.for_update(record, :evaluate_activation, params), actor: actor)
      :sync_draft_mo ->
        Ash.update(Ash.Changeset.for_update(record, :sync_draft_mo, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
