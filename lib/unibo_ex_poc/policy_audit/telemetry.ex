defmodule UniboExPoc.PolicyAudit.Telemetry do
  @moduledoc """
  Ash 权限判定 Telemetry 监听器。
  """

  use GenServer
  require Logger

  alias UniboExPoc.PolicyAudit.PolicyAuditLogger

  @app :unibo_ex_poc
  @default_events [
    [:ash, :accounting, :action, :stop],
    [:ash, :accounting, :create, :stop],
    [:ash, :accounting, :destroy, :stop],
    [:ash, :accounting, :read, :stop],
    [:ash, :accounting, :update, :stop],
    [:ash, :analytic, :action, :stop],
    [:ash, :analytic, :create, :stop],
    [:ash, :analytic, :destroy, :stop],
    [:ash, :analytic, :read, :stop],
    [:ash, :analytic, :update, :stop],
    [:ash, :approvals, :action, :stop],
    [:ash, :approvals, :create, :stop],
    [:ash, :approvals, :destroy, :stop],
    [:ash, :approvals, :read, :stop],
    [:ash, :approvals, :update, :stop],
    [:ash, :barcode, :action, :stop],
    [:ash, :barcode, :create, :stop],
    [:ash, :barcode, :destroy, :stop],
    [:ash, :barcode, :read, :stop],
    [:ash, :barcode, :update, :stop],
    [:ash, :blog, :action, :stop],
    [:ash, :blog, :create, :stop],
    [:ash, :blog, :destroy, :stop],
    [:ash, :blog, :read, :stop],
    [:ash, :blog, :update, :stop],
    [:ash, :calendar, :action, :stop],
    [:ash, :calendar, :create, :stop],
    [:ash, :calendar, :destroy, :stop],
    [:ash, :calendar, :read, :stop],
    [:ash, :calendar, :update, :stop],
    [:ash, :communication, :action, :stop],
    [:ash, :communication, :create, :stop],
    [:ash, :communication, :destroy, :stop],
    [:ash, :communication, :read, :stop],
    [:ash, :communication, :update, :stop],
    [:ash, :crm, :action, :stop],
    [:ash, :crm, :create, :stop],
    [:ash, :crm, :destroy, :stop],
    [:ash, :crm, :read, :stop],
    [:ash, :crm, :update, :stop],
    [:ash, :currency, :action, :stop],
    [:ash, :currency, :create, :stop],
    [:ash, :currency, :destroy, :stop],
    [:ash, :currency, :read, :stop],
    [:ash, :currency, :update, :stop],
    [:ash, :data_recycle, :action, :stop],
    [:ash, :data_recycle, :create, :stop],
    [:ash, :data_recycle, :destroy, :stop],
    [:ash, :data_recycle, :read, :stop],
    [:ash, :data_recycle, :update, :stop],
    [:ash, :delivery, :action, :stop],
    [:ash, :delivery, :create, :stop],
    [:ash, :delivery, :destroy, :stop],
    [:ash, :delivery, :read, :stop],
    [:ash, :delivery, :update, :stop],
    [:ash, :documents, :action, :stop],
    [:ash, :documents, :create, :stop],
    [:ash, :documents, :destroy, :stop],
    [:ash, :documents, :read, :stop],
    [:ash, :documents, :update, :stop],
    [:ash, :e_learning, :action, :stop],
    [:ash, :e_learning, :create, :stop],
    [:ash, :e_learning, :destroy, :stop],
    [:ash, :e_learning, :read, :stop],
    [:ash, :e_learning, :update, :stop],
    [:ash, :ecommerce, :action, :stop],
    [:ash, :ecommerce, :create, :stop],
    [:ash, :ecommerce, :destroy, :stop],
    [:ash, :ecommerce, :read, :stop],
    [:ash, :ecommerce, :update, :stop],
    [:ash, :events, :action, :stop],
    [:ash, :events, :create, :stop],
    [:ash, :events, :destroy, :stop],
    [:ash, :events, :read, :stop],
    [:ash, :events, :update, :stop],
    [:ash, :expenses, :action, :stop],
    [:ash, :expenses, :create, :stop],
    [:ash, :expenses, :destroy, :stop],
    [:ash, :expenses, :read, :stop],
    [:ash, :expenses, :update, :stop],
    [:ash, :fleet, :action, :stop],
    [:ash, :fleet, :create, :stop],
    [:ash, :fleet, :destroy, :stop],
    [:ash, :fleet, :read, :stop],
    [:ash, :fleet, :update, :stop],
    [:ash, :forum, :action, :stop],
    [:ash, :forum, :create, :stop],
    [:ash, :forum, :destroy, :stop],
    [:ash, :forum, :read, :stop],
    [:ash, :forum, :update, :stop],
    [:ash, :gamification, :action, :stop],
    [:ash, :gamification, :create, :stop],
    [:ash, :gamification, :destroy, :stop],
    [:ash, :gamification, :read, :stop],
    [:ash, :gamification, :update, :stop],
    [:ash, :helpdesk, :action, :stop],
    [:ash, :helpdesk, :create, :stop],
    [:ash, :helpdesk, :destroy, :stop],
    [:ash, :helpdesk, :read, :stop],
    [:ash, :helpdesk, :update, :stop],
    [:ash, :hr, :action, :stop],
    [:ash, :hr, :create, :stop],
    [:ash, :hr, :destroy, :stop],
    [:ash, :hr, :read, :stop],
    [:ash, :hr, :update, :stop],
    [:ash, :inventory, :action, :stop],
    [:ash, :inventory, :create, :stop],
    [:ash, :inventory, :destroy, :stop],
    [:ash, :inventory, :read, :stop],
    [:ash, :inventory, :update, :stop],
    [:ash, :io_t, :action, :stop],
    [:ash, :io_t, :create, :stop],
    [:ash, :io_t, :destroy, :stop],
    [:ash, :io_t, :read, :stop],
    [:ash, :io_t, :update, :stop],
    [:ash, :knowledge, :action, :stop],
    [:ash, :knowledge, :create, :stop],
    [:ash, :knowledge, :destroy, :stop],
    [:ash, :knowledge, :read, :stop],
    [:ash, :knowledge, :update, :stop],
    [:ash, :live_chat, :action, :stop],
    [:ash, :live_chat, :create, :stop],
    [:ash, :live_chat, :destroy, :stop],
    [:ash, :live_chat, :read, :stop],
    [:ash, :live_chat, :update, :stop],
    [:ash, :loyalty, :action, :stop],
    [:ash, :loyalty, :create, :stop],
    [:ash, :loyalty, :destroy, :stop],
    [:ash, :loyalty, :read, :stop],
    [:ash, :loyalty, :update, :stop],
    [:ash, :lunch, :action, :stop],
    [:ash, :lunch, :create, :stop],
    [:ash, :lunch, :destroy, :stop],
    [:ash, :lunch, :read, :stop],
    [:ash, :lunch, :update, :stop],
    [:ash, :maintenance, :action, :stop],
    [:ash, :maintenance, :create, :stop],
    [:ash, :maintenance, :destroy, :stop],
    [:ash, :maintenance, :read, :stop],
    [:ash, :maintenance, :update, :stop],
    [:ash, :manufacturing, :action, :stop],
    [:ash, :manufacturing, :create, :stop],
    [:ash, :manufacturing, :destroy, :stop],
    [:ash, :manufacturing, :read, :stop],
    [:ash, :manufacturing, :update, :stop],
    [:ash, :marketing, :action, :stop],
    [:ash, :marketing, :create, :stop],
    [:ash, :marketing, :destroy, :stop],
    [:ash, :marketing, :read, :stop],
    [:ash, :marketing, :update, :stop],
    [:ash, :membership, :action, :stop],
    [:ash, :membership, :create, :stop],
    [:ash, :membership, :destroy, :stop],
    [:ash, :membership, :read, :stop],
    [:ash, :membership, :update, :stop],
    [:ash, :ofbiz_accounting, :action, :stop],
    [:ash, :ofbiz_accounting, :create, :stop],
    [:ash, :ofbiz_accounting, :destroy, :stop],
    [:ash, :ofbiz_accounting, :read, :stop],
    [:ash, :ofbiz_accounting, :update, :stop],
    [:ash, :ofbiz_common, :action, :stop],
    [:ash, :ofbiz_common, :create, :stop],
    [:ash, :ofbiz_common, :destroy, :stop],
    [:ash, :ofbiz_common, :read, :stop],
    [:ash, :ofbiz_common, :update, :stop],
    [:ash, :ofbiz_content, :action, :stop],
    [:ash, :ofbiz_content, :create, :stop],
    [:ash, :ofbiz_content, :destroy, :stop],
    [:ash, :ofbiz_content, :read, :stop],
    [:ash, :ofbiz_content, :update, :stop],
    [:ash, :ofbiz_human_res, :action, :stop],
    [:ash, :ofbiz_human_res, :create, :stop],
    [:ash, :ofbiz_human_res, :destroy, :stop],
    [:ash, :ofbiz_human_res, :read, :stop],
    [:ash, :ofbiz_human_res, :update, :stop],
    [:ash, :ofbiz_manufacturing, :action, :stop],
    [:ash, :ofbiz_manufacturing, :create, :stop],
    [:ash, :ofbiz_manufacturing, :destroy, :stop],
    [:ash, :ofbiz_manufacturing, :read, :stop],
    [:ash, :ofbiz_manufacturing, :update, :stop],
    [:ash, :ofbiz_marketing, :action, :stop],
    [:ash, :ofbiz_marketing, :create, :stop],
    [:ash, :ofbiz_marketing, :destroy, :stop],
    [:ash, :ofbiz_marketing, :read, :stop],
    [:ash, :ofbiz_marketing, :update, :stop],
    [:ash, :ofbiz_order, :action, :stop],
    [:ash, :ofbiz_order, :create, :stop],
    [:ash, :ofbiz_order, :destroy, :stop],
    [:ash, :ofbiz_order, :read, :stop],
    [:ash, :ofbiz_order, :update, :stop],
    [:ash, :ofbiz_party, :action, :stop],
    [:ash, :ofbiz_party, :create, :stop],
    [:ash, :ofbiz_party, :destroy, :stop],
    [:ash, :ofbiz_party, :read, :stop],
    [:ash, :ofbiz_party, :update, :stop],
    [:ash, :ofbiz_product, :action, :stop],
    [:ash, :ofbiz_product, :create, :stop],
    [:ash, :ofbiz_product, :destroy, :stop],
    [:ash, :ofbiz_product, :read, :stop],
    [:ash, :ofbiz_product, :update, :stop],
    [:ash, :ofbiz_security, :action, :stop],
    [:ash, :ofbiz_security, :create, :stop],
    [:ash, :ofbiz_security, :destroy, :stop],
    [:ash, :ofbiz_security, :read, :stop],
    [:ash, :ofbiz_security, :update, :stop],
    [:ash, :ofbiz_service, :action, :stop],
    [:ash, :ofbiz_service, :create, :stop],
    [:ash, :ofbiz_service, :destroy, :stop],
    [:ash, :ofbiz_service, :read, :stop],
    [:ash, :ofbiz_service, :update, :stop],
    [:ash, :ofbiz_shipment, :action, :stop],
    [:ash, :ofbiz_shipment, :create, :stop],
    [:ash, :ofbiz_shipment, :destroy, :stop],
    [:ash, :ofbiz_shipment, :read, :stop],
    [:ash, :ofbiz_shipment, :update, :stop],
    [:ash, :ofbiz_work_effort, :action, :stop],
    [:ash, :ofbiz_work_effort, :create, :stop],
    [:ash, :ofbiz_work_effort, :destroy, :stop],
    [:ash, :ofbiz_work_effort, :read, :stop],
    [:ash, :ofbiz_work_effort, :update, :stop],
    [:ash, :organization, :action, :stop],
    [:ash, :organization, :create, :stop],
    [:ash, :organization, :destroy, :stop],
    [:ash, :organization, :read, :stop],
    [:ash, :organization, :update, :stop],
    [:ash, :payment, :action, :stop],
    [:ash, :payment, :create, :stop],
    [:ash, :payment, :destroy, :stop],
    [:ash, :payment, :read, :stop],
    [:ash, :payment, :update, :stop],
    [:ash, :plm, :action, :stop],
    [:ash, :plm, :create, :stop],
    [:ash, :plm, :destroy, :stop],
    [:ash, :plm, :read, :stop],
    [:ash, :plm, :update, :stop],
    [:ash, :pos, :action, :stop],
    [:ash, :pos, :create, :stop],
    [:ash, :pos, :destroy, :stop],
    [:ash, :pos, :read, :stop],
    [:ash, :pos, :update, :stop],
    [:ash, :project, :action, :stop],
    [:ash, :project, :create, :stop],
    [:ash, :project, :destroy, :stop],
    [:ash, :project, :read, :stop],
    [:ash, :project, :update, :stop],
    [:ash, :purchasing, :action, :stop],
    [:ash, :purchasing, :create, :stop],
    [:ash, :purchasing, :destroy, :stop],
    [:ash, :purchasing, :read, :stop],
    [:ash, :purchasing, :update, :stop],
    [:ash, :quality, :action, :stop],
    [:ash, :quality, :create, :stop],
    [:ash, :quality, :destroy, :stop],
    [:ash, :quality, :read, :stop],
    [:ash, :quality, :update, :stop],
    [:ash, :rating, :action, :stop],
    [:ash, :rating, :create, :stop],
    [:ash, :rating, :destroy, :stop],
    [:ash, :rating, :read, :stop],
    [:ash, :rating, :update, :stop],
    [:ash, :rental, :action, :stop],
    [:ash, :rental, :create, :stop],
    [:ash, :rental, :destroy, :stop],
    [:ash, :rental, :read, :stop],
    [:ash, :rental, :update, :stop],
    [:ash, :repair, :action, :stop],
    [:ash, :repair, :create, :stop],
    [:ash, :repair, :destroy, :stop],
    [:ash, :repair, :read, :stop],
    [:ash, :repair, :update, :stop],
    [:ash, :sales, :action, :stop],
    [:ash, :sales, :create, :stop],
    [:ash, :sales, :destroy, :stop],
    [:ash, :sales, :read, :stop],
    [:ash, :sales, :update, :stop],
    [:ash, :sign, :action, :stop],
    [:ash, :sign, :create, :stop],
    [:ash, :sign, :destroy, :stop],
    [:ash, :sign, :read, :stop],
    [:ash, :sign, :update, :stop],
    [:ash, :spreadsheet, :action, :stop],
    [:ash, :spreadsheet, :create, :stop],
    [:ash, :spreadsheet, :destroy, :stop],
    [:ash, :spreadsheet, :read, :stop],
    [:ash, :spreadsheet, :update, :stop],
    [:ash, :studio, :action, :stop],
    [:ash, :studio, :create, :stop],
    [:ash, :studio, :destroy, :stop],
    [:ash, :studio, :read, :stop],
    [:ash, :studio, :update, :stop],
    [:ash, :subscriptions, :action, :stop],
    [:ash, :subscriptions, :create, :stop],
    [:ash, :subscriptions, :destroy, :stop],
    [:ash, :subscriptions, :read, :stop],
    [:ash, :subscriptions, :update, :stop],
    [:ash, :survey, :action, :stop],
    [:ash, :survey, :create, :stop],
    [:ash, :survey, :destroy, :stop],
    [:ash, :survey, :read, :stop],
    [:ash, :survey, :update, :stop],
    [:ash, :travel, :action, :stop],
    [:ash, :travel, :create, :stop],
    [:ash, :travel, :destroy, :stop],
    [:ash, :travel, :read, :stop],
    [:ash, :travel, :update, :stop],
    [:ash, :uom, :action, :stop],
    [:ash, :uom, :create, :stop],
    [:ash, :uom, :destroy, :stop],
    [:ash, :uom, :read, :stop],
    [:ash, :uom, :update, :stop],
    [:ash, :website, :action, :stop],
    [:ash, :website, :create, :stop],
    [:ash, :website, :destroy, :stop],
    [:ash, :website, :read, :stop],
    [:ash, :website, :update, :stop]
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
