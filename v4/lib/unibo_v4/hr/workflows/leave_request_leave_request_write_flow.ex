defmodule UniboV4.HR.Workflows.LeaveRequest.LeaveRequestWriteFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.HR.LeaveRequest

  def steps do
    [:create, :action_confirm, :action_approve, :action_validate, :action_refuse, :action_draft]
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
        Ash.create(Ash.Changeset.for_create(LeaveRequest, :create, params), actor: actor)
      :action_confirm ->
        Ash.update(Ash.Changeset.for_update(record, :action_confirm, params), actor: actor)
      :action_approve ->
        Ash.update(Ash.Changeset.for_update(record, :action_approve, params), actor: actor)
      :action_validate ->
        Ash.update(Ash.Changeset.for_update(record, :action_validate, params), actor: actor)
      :action_refuse ->
        Ash.update(Ash.Changeset.for_update(record, :action_refuse, params), actor: actor)
      :action_draft ->
        Ash.update(Ash.Changeset.for_update(record, :action_draft, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
