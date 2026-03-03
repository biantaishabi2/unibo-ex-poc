defmodule UniboV4.Calendar.Workflows.CalendarEvent.CalendarEventLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Calendar.CalendarEvent

  def steps do
    [:create, :update, :confirm, :cancel, :revert_to_draft, :mark_tentative, :destroy]
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
        Ash.create(Ash.Changeset.for_create(CalendarEvent, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :confirm ->
        Ash.update(Ash.Changeset.for_update(record, :confirm, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      :revert_to_draft ->
        Ash.update(Ash.Changeset.for_update(record, :revert_to_draft, params), actor: actor)
      :mark_tentative ->
        Ash.update(Ash.Changeset.for_update(record, :mark_tentative, params), actor: actor)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
