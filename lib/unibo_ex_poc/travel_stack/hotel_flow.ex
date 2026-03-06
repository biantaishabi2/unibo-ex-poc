defmodule UniboExPoc.TravelStack.HotelFlow do
  @moduledoc """
  hotel 场景的测试辅助闭环。

  该模块仅用于宿主 bridge 合约相关测试，不作为 travel 的主集成入口。
  travel 主路径以 compile-project 产出的 Ash + GraphQL schema 为准。
  """

  alias UniboExPoc.Travel.Travel.TravelFulfillment
  alias UniboExPoc.Travel.Travel.TravelOrder
  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.EligibilityOrQuote
  alias UniboExPoc.TravelHost.HostConfig
  alias UniboExPoc.TravelHost.PaymentExecution
  alias UniboExPoc.TravelSupplier.HotelBookingRequest
  alias UniboExPoc.TravelSupplier.HotelMockAdapter

  @doc """
  测试辅助下单流程：返回宿主侧预检/支付与 supplier mock 结果。
  """
  @spec book(map(), keyword()) :: {:ok, map()} | {:error, term()}
  def book(input, opts \\ []) do
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
         {:ok, supplier_result} <- HotelMockAdapter.book(supplier_request, payment) do
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
end
