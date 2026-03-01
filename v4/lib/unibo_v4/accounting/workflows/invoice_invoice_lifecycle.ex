defmodule UniboV4.Accounting.Workflows.Invoice.InvoiceLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Accounting.Invoice

  def steps do
    [:create, :approve, :send, :void]
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
        Ash.create(Ash.Changeset.for_create(Invoice, :create, params), actor: actor)
      :approve ->
        Ash.update(Ash.Changeset.for_update(record, :approve, params), actor: actor)
      :send ->
        Ash.update(Ash.Changeset.for_update(record, :send, params), actor: actor)
      :void ->
        Ash.update(Ash.Changeset.for_update(record, :void, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
