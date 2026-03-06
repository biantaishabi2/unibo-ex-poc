defmodule UniboExPoc.TravelStack.HotelFlow do
  @moduledoc """
  hotel 场景的测试辅助闭环。

  该模块仅用于宿主 bridge 合约相关测试，不作为 travel 的主集成入口。
  travel 主路径以 compile-project 产出的 Ash + GraphQL schema 为准。
  """

  alias UniboExPoc.Travel.TravelFulfillment
  alias UniboExPoc.Travel.TravelOrder
  alias UniboExPoc.TravelHost.DefaultBridge
  alias UniboExPoc.TravelSupplier.HotelBookingRequest
  alias UniboExPoc.TravelSupplier.HotelMockAdapter

  @doc """
  测试辅助下单流程：返回宿主侧预检/支付与 supplier mock 结果。
  """
  @spec book(map(), keyword()) :: {:ok, map()} | {:error, term()}
  def book(input, opts \\ []) do
    adapter = Keyword.get(opts, :supplier_adapter, HotelMockAdapter)
    adapter_opts = Keyword.get(opts, :supplier_adapter_opts, [])

    {bridge, bridge_opts} = bridge_spec(input, opts)

    with {:ok, context} <- bridge.resolve_context(Map.fetch!(input, :context), bridge_opts),
         order_attrs <- Map.put(Map.fetch!(input, :order), :product_type, :hotel),
         {:ok, quote} <- bridge.quote(order_attrs, context, bridge_opts),
         true <- quote.allowed? or {:error, quote.reason},
         {:ok, payment} <-
           bridge.execute_payment(payment_method(opts, quote), quote, bridge_opts),
         :approved <- payment.status,
         supplier_request <- HotelBookingRequest.from_order(order_attrs, context),
         true <- adapter_compatible?(adapter) or {:error, :invalid_supplier_adapter},
         {:ok, supplier_result} <- adapter.book(supplier_request, payment, adapter_opts) do
      {:ok,
       %{
         context: context,
         quote: quote,
         payment: payment,
         supplier_request: supplier_request,
         order: %{
           resource_module: TravelOrder,
           order_no: order_attrs.order_no,
           product_type: :hotel,
           status: :booked,
           payment_status: :paid,
           supplier_order_ref: supplier_result.supplier_booking_ref
         },
         fulfillment: %{
           resource_module: TravelFulfillment,
           status: :confirmed,
           supplier_booking_ref: supplier_result.supplier_booking_ref,
           voucher_or_ticket_ref: supplier_result.voucher_ref
         }
       }}
    else
      {:error, reason} -> {:error, reason}
      :declined -> {:error, :payment_declined}
    end
  end

  defp adapter_compatible?(adapter) do
    Code.ensure_loaded?(adapter) and
      function_exported?(adapter, :book, 3) and
      function_exported?(adapter, :query_booking_status, 2) and
      function_exported?(adapter, :pull_incremental_updates, 2)
  end

  defp bridge_spec(input, opts) do
    base_bridge = Application.get_env(:travel, :travel_host_bridge, DefaultBridge)

    {bridge, configured_bridge_opts} =
      case Keyword.get(opts, :bridge, base_bridge) do
        {module, module_opts} -> {module, module_opts}
        module -> {module, []}
      end

    bridge_opts =
      configured_bridge_opts
      |> Keyword.merge(Keyword.get(opts, :bridge_opts, []))
      |> Keyword.put(:host_config, Map.get(input, :host_config))
      |> Keyword.put(:available_points, Keyword.get(opts, :available_points, 0))
      |> Keyword.put(:payment_request, Map.get(input, :payment, %{}))

    {bridge, bridge_opts}
  end

  defp payment_method(opts, quote) do
    Keyword.get(opts, :payment_method, quote.recommended_payment_method)
  end
end
