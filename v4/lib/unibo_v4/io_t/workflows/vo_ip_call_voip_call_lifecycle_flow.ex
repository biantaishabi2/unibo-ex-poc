defmodule UniboV4.IoT.Workflows.VoIpCall.VoipCallLifecycleFlowWorkflow do
  @moduledoc """
  自动生成的工作流编排模块。
  """

  alias UniboV4.IoT.VoIPCall

  def steps do
    [:create, :answer, :add_note, :end_call, :miss, :to_voicemail]
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
        Ash.create(Ash.Changeset.for_create(VoIPCall, :create, params), actor: actor)
      :answer ->
        Ash.update(Ash.Changeset.for_update(record, :answer, params), actor: actor)
      :add_note ->
        Ash.update(Ash.Changeset.for_update(record, :add_note, params), actor: actor)
      :end_call ->
        Ash.update(Ash.Changeset.for_update(record, :end_call, params), actor: actor)
      :miss ->
        Ash.update(Ash.Changeset.for_update(record, :miss, params), actor: actor)
      :to_voicemail ->
        Ash.update(Ash.Changeset.for_update(record, :to_voicemail, params), actor: actor)
      _ -> {:ok, record}
    end
  end
end
