defmodule UniboExPoc.TravelStack.HotelFlow do
  @moduledoc """
  hotel 场景的最小闭环：
  宿主上下文 -> 宿主预检/报价 -> 宿主支付 -> supplier booking -> travel order/fulfillment 结果。
  """

  alias UniboExPoc.Travel.Travel.TravelFulfillment
  alias UniboExPoc.Travel.Travel.TravelOrder
  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.EligibilityOrQuote
  alias UniboExPoc.TravelHost.HostConfig
  alias UniboExPoc.TravelHost.PaymentExecution
  alias UniboExPoc.TravelSupplier.HotelBookingRequest
  alias UniboExPoc.TravelSupplier.HotelMockAdapter

  @spec book(map(), keyword()) :: {:ok, map()} | {:error, term()}
  def book(input, opts \\ []) do
    adapter = Keyword.get(opts, :supplier_adapter, HotelMockAdapter)
    adapter_opts = Keyword.get(opts, :supplier_adapter_opts, [])

    with {:ok, context} <- CallerContext.normalize(Map.fetch!(input, :context)),
         config <- HostConfig.new(Map.fetch!(input, :host_config)),
         order_attrs <- Map.put(Map.fetch!(input, :order), :product_type, :hotel),
         quote <-
           EligibilityOrQuote.build(order_attrs, context, config,
             available_points: Keyword.get(opts, :available_points, 0)
           ),
         true <- quote.allowed? or {:error, quote.reason},
         {:ok, payment} <-
           PaymentExecution.execute(
             Keyword.get(opts, :payment_method, quote.recommended_payment_method),
             quote,
             []
           ),
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
end
