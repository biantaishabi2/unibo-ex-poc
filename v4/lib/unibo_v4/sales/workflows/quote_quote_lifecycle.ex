defmodule UniboV4.Sales.Workflows.Quote.QuoteLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Sales.Quote

  def steps do
    [:create, :submit, :accept, :reject]
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
        Ash.create(Ash.Changeset.for_create(Quote, :create, params), actor: actor)
      :submit ->
        Ash.update(Ash.Changeset.for_update(record, :submit, params), actor: actor)
      :accept ->
        Ash.update(Ash.Changeset.for_update(record, :accept, params), actor: actor)
      :reject ->
        Ash.update(Ash.Changeset.for_update(record, :reject, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
