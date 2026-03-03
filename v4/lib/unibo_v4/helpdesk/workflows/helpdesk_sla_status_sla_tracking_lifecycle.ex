defmodule UniboV4.Helpdesk.Workflows.HelpdeskSlaStatus.SlaTrackingLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Helpdesk.HelpdeskSLAStatus

  def steps do
    [:create, :check_and_update, :mark_reached, :mark_failed, :accumulate_excluded_time]
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
        Ash.create(Ash.Changeset.for_create(HelpdeskSLAStatus, :create, params), actor: actor)
      :check_and_update ->
        Ash.update(Ash.Changeset.for_update(record, :check_and_update, params), actor: actor)
      :mark_reached ->
        Ash.update(Ash.Changeset.for_update(record, :mark_reached, params), actor: actor)
      :mark_failed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_failed, params), actor: actor)
      :accumulate_excluded_time ->
        Ash.update(Ash.Changeset.for_update(record, :accumulate_excluded_time, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
