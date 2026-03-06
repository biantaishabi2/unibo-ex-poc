defmodule UniboExPoc.TravelSupplier.HotelMockAdapter do
  @moduledoc """
  hotel supplier adapter 的最小 stub。
  这里只验证边界和返回结构，不接真实供应商。
  """

  alias UniboExPoc.TravelHost.PaymentExecution
  alias UniboExPoc.TravelSupplier.HotelBookingRequest

  @spec book(HotelBookingRequest.t(), PaymentExecution.t()) :: {:ok, map()} | {:error, atom()}
  def book(%HotelBookingRequest{} = request, %PaymentExecution{status: :approved}) do
    {:ok,
     %{
       supplier_booking_ref: "hotel-booking-" <> request.order_no,
       voucher_ref: "voucher-" <> request.order_no,
       supplier_status: :confirmed
     }}
  end

  def book(%HotelBookingRequest{}, %PaymentExecution{}), do: {:error, :payment_not_approved}
end
