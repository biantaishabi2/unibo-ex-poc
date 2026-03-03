defmodule UniboV4.Marketing.Workflows.Event.EventLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Marketing.Event

  def steps do
    [:create, :update, :publish, :complete, :cancel, :set_done]
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
        Ash.create(Ash.Changeset.for_create(Event, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :publish ->
        Ash.update(Ash.Changeset.for_update(record, :publish, params), actor: actor)
      :complete ->
        Ash.update(Ash.Changeset.for_update(record, :complete, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      :set_done ->
        Ash.update(Ash.Changeset.for_update(record, :set_done, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
