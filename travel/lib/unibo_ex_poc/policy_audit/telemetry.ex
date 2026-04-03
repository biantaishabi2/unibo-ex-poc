defmodule UniboExPoc.PolicyAudit.Telemetry do
  @moduledoc """
  Ash 权限判定 Telemetry 监听器。
  """

  use GenServer
  require Logger

  alias UniboExPoc.PolicyAudit.PolicyAuditLogger

  @app :travel
  @default_events [
    [:ash, :approvals, :action, :stop],
    [:ash, :approvals, :create, :stop],
    [:ash, :approvals, :destroy, :stop],
    [:ash, :approvals, :read, :stop],
    [:ash, :approvals, :update, :stop],
    [:ash, :hr, :action, :stop],
    [:ash, :hr, :create, :stop],
    [:ash, :hr, :destroy, :stop],
    [:ash, :hr, :read, :stop],
    [:ash, :hr, :update, :stop],
    [:ash, :organization, :action, :stop],
    [:ash, :organization, :create, :stop],
    [:ash, :organization, :destroy, :stop],
    [:ash, :organization, :read, :stop],
    [:ash, :organization, :update, :stop],
    [:ash, :travel, :action, :stop],
    [:ash, :travel, :create, :stop],
    [:ash, :travel, :destroy, :stop],
    [:ash, :travel, :read, :stop],
    [:ash, :travel, :update, :stop]
  ]

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl true
  def init(state) do
    if PolicyAuditLogger.enabled?() do
      Enum.each(events(), fn event ->
        :telemetry.attach(handler_id(event), event, &__MODULE__.handle_event/4, %{})
      end)
    end

    {:ok, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Enum.each(events(), fn event ->
      :telemetry.detach(handler_id(event))
    end)

    :ok
  end

  def handle_event(event, measurements, metadata, _config) do
    PolicyAuditLogger.record(%{
      timestamp: DateTime.utc_now(),
      actor_id: actor_id(metadata),
      resource: resource_name(metadata),
      action: action_name(metadata),
      result: policy_result(metadata),
      policies_evaluated: policy_details(metadata),
      metadata: %{
        event: Enum.map(event, &to_string/1),
        measurements: measurements
      }
    })

    :ok
  rescue
    reason ->
      Logger.debug("policy audit telemetry 处理失败: #{inspect(reason)}")
      :ok
  end

  defp events do
    Application.get_env(@app, __MODULE__, [])
    |> Keyword.get(:events, @default_events)
  end

  defp handler_id(event), do: {__MODULE__, event}

  defp actor_id(metadata) do
    actor = Map.get(metadata, :actor) || Map.get(metadata, "actor")
    if is_map(actor), do: Map.get(actor, :id) || Map.get(actor, "id"), else: nil
  end

  defp resource_name(metadata) do
    metadata
    |> first_value([:resource, :resource_name, "resource", "resource_name"])
    |> inspect()
  end

  defp action_name(metadata) do
    metadata
    |> first_value([:action, :action_name, :requested_action, "action", "action_name"])
    |> to_string()
  end

  defp policy_result(metadata) do
    case first_value(metadata, [:result, :authorized?, "result", "authorized?"]) do
      true -> "authorized"
      :authorized -> "authorized"
      false -> "forbidden"
      :forbidden -> "forbidden"
      other when is_binary(other) -> other
      _ -> "unknown"
    end
  end

  defp policy_details(metadata) do
    first_value(metadata, [
      :policies_evaluated,
      :policies,
      :policy_breakdown,
      "policies_evaluated",
      "policies",
      "policy_breakdown"
    ]) || []
  end

  defp first_value(map, keys) do
    Enum.find_value(keys, fn key -> Map.get(map, key) end)
  end
end
