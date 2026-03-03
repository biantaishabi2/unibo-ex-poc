defmodule UniboV4.Payment.Workflows.Payment.PaymentLifecycleWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Payment.Payment

  def steps do
    [:create, :update, :submit, :authorize, :capture, :refund, :mark_failed, :cancel, :destroy]
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
        Ash.create(Ash.Changeset.for_create(Payment, :create, params), actor: actor)
      :update ->
        Ash.update(Ash.Changeset.for_update(record, :update, params), actor: actor)
      :submit ->
        Ash.update(Ash.Changeset.for_update(record, :submit, params), actor: actor)
      :authorize ->
        Ash.update(Ash.Changeset.for_update(record, :authorize, params), actor: actor)
      :capture ->
        Ash.update(Ash.Changeset.for_update(record, :capture, params), actor: actor)
      :refund ->
        Ash.update(Ash.Changeset.for_update(record, :refund, params), actor: actor)
      :mark_failed ->
        Ash.update(Ash.Changeset.for_update(record, :mark_failed, params), actor: actor)
      :cancel ->
        Ash.update(Ash.Changeset.for_update(record, :cancel, params), actor: actor)
      :destroy ->
        Ash.destroy(Ash.Changeset.for_destroy(record, :destroy, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
