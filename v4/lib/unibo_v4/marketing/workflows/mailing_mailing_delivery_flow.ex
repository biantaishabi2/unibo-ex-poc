defmodule UniboV4.Marketing.Workflows.Mailing.MailingDeliveryFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.Marketing.Mailing

  def steps do
    [:create, :schedule, :put_in_queue, :launch, :retry_failed]
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
        Ash.create(Ash.Changeset.for_create(Mailing, :create, params), actor: actor)
      :schedule ->
        Ash.update(Ash.Changeset.for_update(record, :schedule, params), actor: actor)
      :put_in_queue ->
        Ash.update(Ash.Changeset.for_update(record, :put_in_queue, params), actor: actor)
      :launch ->
        Ash.update(Ash.Changeset.for_update(record, :launch, params), actor: actor)
      :retry_failed ->
        Ash.update(Ash.Changeset.for_update(record, :retry_failed, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
