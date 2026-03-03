defmodule UniboV4.Helpdesk.Workflows.HelpdeskTicket.TicketLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Helpdesk.HelpdeskTicket

  def steps do
    [:create, :assign, :change_stage, :resolve, :close, :reopen, :archive, :update_priority, :plan_intervention]
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
        Ash.create(Ash.Changeset.for_create(HelpdeskTicket, :create, params), actor: actor)
      :assign ->
        Ash.update(Ash.Changeset.for_update(record, :assign, params), actor: actor)
      :change_stage ->
        Ash.update(Ash.Changeset.for_update(record, :change_stage, params), actor: actor)
      :resolve ->
        Ash.update(Ash.Changeset.for_update(record, :resolve, params), actor: actor)
      :close ->
        Ash.update(Ash.Changeset.for_update(record, :close, params), actor: actor)
      :reopen ->
        Ash.update(Ash.Changeset.for_update(record, :reopen, params), actor: actor)
      :archive ->
        Ash.update(Ash.Changeset.for_update(record, :archive, params), actor: actor)
      :update_priority ->
        Ash.update(Ash.Changeset.for_update(record, :update_priority, params), actor: actor)
      :plan_intervention ->
        Ash.update(Ash.Changeset.for_update(record, :plan_intervention, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
