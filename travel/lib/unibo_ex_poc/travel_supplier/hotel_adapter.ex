defmodule UniboExPoc.TravelSupplier.HotelAdapter do
  @moduledoc """
  hotel supplier adapter 行为契约。
  本阶段只定义可执行边界，真实 provider 实现后续补齐。
  """

  alias UniboExPoc.TravelHost.PaymentExecution
  alias UniboExPoc.TravelSupplier.HotelBookingRequest

  @type error_code ::
          :supplier_rejected
          | :timeout
          | :temporary_unavailable
          | :invalid_request
          | :unexpected_response

  @type adapter_error :: %{
          required(:code) => error_code(),
          required(:retryable?) => boolean(),
          optional(:message) => String.t(),
          optional(:raw) => map()
        }

  @type booking_result :: %{
          required(:supplier_booking_ref) => String.t(),
          required(:supplier_status) => atom(),
          optional(:voucher_ref) => String.t() | nil,
          optional(:raw) => map()
        }

  @type booking_status_result :: %{
          required(:supplier_booking_ref) => String.t(),
          required(:supplier_status) => atom(),
          optional(:occurred_at) => DateTime.t(),
          optional(:raw) => map()
        }

  @type incremental_update :: %{
          required(:supplier_booking_ref) => String.t(),
          required(:order_no) => String.t(),
          required(:supplier_status) => atom(),
          optional(:occurred_at) => DateTime.t(),
          optional(:raw) => map()
        }

  @type incremental_cursor :: map() | nil

  @callback book(HotelBookingRequest.t(), PaymentExecution.t(), keyword()) ::
              {:ok, booking_result()} | {:error, adapter_error()}

  @callback query_booking_status(String.t(), keyword()) ::
              {:ok, booking_status_result()} | {:error, adapter_error()}

  @callback pull_incremental_updates(incremental_cursor(), keyword()) ::
              {:ok, %{events: [incremental_update()], next_cursor: incremental_cursor()}}
              | {:error, adapter_error()}
end
