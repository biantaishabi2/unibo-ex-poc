defmodule UniboV4.Accounting.Workflows.JournalEntry.JournalEntryLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Accounting.JournalEntry

  def steps do
    [:create, :post, :cancel, :reset_to_draft]
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
        Ash.create(Ash.Changeset.for_create(JournalEntry, :create, params), actor: actor)
      :post ->
        Ash.update(Ash.Changeset.for_update(record, :post, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      :reset_to_draft ->
        Ash.update(Ash.Changeset.for_update(record, :reset_to_draft, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
