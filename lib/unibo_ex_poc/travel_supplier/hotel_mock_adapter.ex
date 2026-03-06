defmodule UniboExPoc.TravelSupplier.HotelMockAdapter do
  @moduledoc """
  hotel supplier adapter 的最小 mock。
  只用于验证行为契约、错误语义和增量同步骨架，不接真实供应商。
  """

  @behaviour UniboExPoc.TravelSupplier.HotelAdapter

  alias UniboExPoc.TravelHost.PaymentExecution
  alias UniboExPoc.TravelSupplier.HotelAdapter
  alias UniboExPoc.TravelSupplier.HotelBookingRequest

  @spec book(HotelBookingRequest.t(), PaymentExecution.t()) ::
          {:ok, HotelAdapter.booking_result()} | {:error, HotelAdapter.adapter_error()}
  def book(%HotelBookingRequest{} = request, %PaymentExecution{} = payment) do
    book(request, payment, [])
  end

  @impl true
  @spec book(HotelBookingRequest.t(), PaymentExecution.t(), keyword()) ::
          {:ok, HotelAdapter.booking_result()} | {:error, HotelAdapter.adapter_error()}
  def book(%HotelBookingRequest{} = request, %PaymentExecution{} = payment, opts) do
    case Keyword.get(opts, :simulate) do
      :supplier_rejected ->
        {:error,
         error(:supplier_rejected, false, "supplier rejected booking", %{
           reason: "rate_plan_closed"
         })}

      :timeout ->
        {:error, error(:timeout, true, "supplier request timeout", %{phase: "create_order"})}

      :temporary_unavailable ->
        {:error,
         error(:temporary_unavailable, true, "supplier temporary unavailable", %{status: 503})}

      :invalid_request ->
        {:error,
         error(:invalid_request, false, "supplier rejected invalid request", %{
           field: "hotel_code"
         })}

      :unexpected_response ->
        {:error,
         error(:unexpected_response, true, "supplier response parse failed", %{body: "N/A"})}

      _ ->
        do_book(request, payment)
    end
  end

  defp do_book(%HotelBookingRequest{} = request, %PaymentExecution{status: :approved}) do
    {:ok,
     %{
       supplier_booking_ref: "hotel-booking-" <> request.order_no,
       voucher_ref: "voucher-" <> request.order_no,
       supplier_status: :confirmed,
       raw: %{source: :mock}
     }}
  end

  defp do_book(%HotelBookingRequest{}, %PaymentExecution{}) do
    {:error, error(:invalid_request, false, "payment not approved", %{field: "payment.status"})}
  end

  @impl true
  @spec query_booking_status(String.t(), keyword()) ::
          {:ok, HotelAdapter.booking_status_result()} | {:error, HotelAdapter.adapter_error()}
  def query_booking_status(supplier_booking_ref, opts) do
    case Keyword.get(opts, :simulate) do
      :timeout ->
        {:error,
         error(:timeout, true, "supplier query timeout", %{phase: "query_booking_status"})}

      _ ->
        status = Keyword.get(opts, :status, :confirmed)
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        {:ok,
         %{
           supplier_booking_ref: supplier_booking_ref,
           supplier_status: status,
           occurred_at: now,
           raw: %{source: :mock}
         }}
    end
  end

  @impl true
  @spec pull_incremental_updates(HotelAdapter.incremental_cursor(), keyword()) ::
          {:ok,
           %{
             events: [HotelAdapter.incremental_update()],
             next_cursor: HotelAdapter.incremental_cursor()
           }}
          | {:error, HotelAdapter.adapter_error()}
  def pull_incremental_updates(cursor, opts) do
    case Keyword.get(opts, :simulate) do
      :timeout ->
        {:error,
         error(:timeout, true, "supplier incremental sync timeout", %{
           phase: "pull_incremental_updates"
         })}

      _ ->
        limit = Keyword.get(opts, :limit, 2)
        offset = cursor_offset(cursor)
        all_events = mock_incremental_events()
        events = all_events |> Enum.drop(offset) |> Enum.take(limit)
        next_cursor = next_cursor(offset, length(events), length(all_events))

        {:ok, %{events: events, next_cursor: next_cursor}}
    end
  end

  defp cursor_offset(%{offset: offset}) when is_integer(offset) and offset >= 0, do: offset
  defp cursor_offset(_), do: 0

  defp next_cursor(offset, fetched_count, total_count)
       when offset + fetched_count < total_count do
    %{offset: offset + fetched_count}
  end

  defp next_cursor(_offset, _fetched_count, _total_count), do: nil

  defp mock_incremental_events do
    [
      %{
        supplier_booking_ref: "hotel-booking-travel-001",
        order_no: "travel-001",
        supplier_status: :confirmed,
        occurred_at: ~U[2026-03-01 10:00:00Z],
        raw: %{supplier_status_code: "CONFIRMED"}
      },
      %{
        supplier_booking_ref: "hotel-booking-travel-002",
        order_no: "travel-002",
        supplier_status: :checked_in,
        occurred_at: ~U[2026-03-01 10:05:00Z],
        raw: %{supplier_status_code: "CHECKED_IN"}
      }
    ]
  end

  defp error(code, retryable?, message, raw) do
    %{code: code, retryable?: retryable?, message: message, raw: raw}
  end
end
