defmodule UniboExPoc.Travel.HotelSupplierAdapterPrepTest do
  use ExUnit.Case, async: true

  alias Travel.TravelStack.HotelFlow
  alias Travel.TravelSupplier.HotelMockAdapter

  test "成功场景：supplier book 返回 confirmed" do
    assert {:ok, result} =
             HotelFlow.book(base_input(), available_points: 1_000, payment_method: :mixed)

    assert result.order.status == :booked
    assert result.fulfillment.status == :confirmed
    assert result.fulfillment.supplier_booking_ref == "hotel-booking-travel-041"
  end

  test "供应商拒绝：返回结构化 supplier_rejected 错误" do
    assert {:error, error} =
             HotelFlow.book(base_input(),
               available_points: 1_000,
               payment_method: :mixed,
               supplier_adapter_opts: [simulate: :supplier_rejected]
             )

    assert error.code == :supplier_rejected
    refute error.retryable?
  end

  test "调用超时：返回可重试 timeout 错误" do
    assert {:error, error} =
             HotelFlow.book(base_input(),
               available_points: 1_000,
               payment_method: :mixed,
               supplier_adapter_opts: [simulate: :timeout]
             )

    assert error.code == :timeout
    assert error.retryable?
  end

  test "状态增量同步：cursor 能前进并返回增量事件" do
    assert {:ok, page1} = HotelMockAdapter.pull_incremental_updates(nil, limit: 1)
    assert length(page1.events) == 1
    assert page1.next_cursor == %{offset: 1}
    assert hd(page1.events).order_no == "travel-001"

    assert {:ok, page2} = HotelMockAdapter.pull_incremental_updates(page1.next_cursor, limit: 1)
    assert length(page2.events) == 1
    assert page2.next_cursor == nil
    assert hd(page2.events).order_no == "travel-002"
  end

  defp base_input do
    %{
      context: %{
        user_id: "user-41",
        member_id: "member-41",
        enterprise_id: "ent-41",
        current_shop_id: "shop-41",
        request_id: "req-41"
      },
      host_config: %{
        travel_enabled: true,
        entry_visible: true,
        points_enabled: true,
        mixed_payment_enabled: true,
        cash_payment_enabled: true,
        points_exchange_rate: "0.01",
        min_points_to_use: 100,
        max_points_deduction_amount: "20",
        visible_enterprise_ids: ["ent-41"],
        allowed_product_types: [:hotel]
      },
      order: %{
        order_no: "travel-041",
        supplier_code: "jd-hotel",
        hotel_code: "hotel-041",
        room_type_code: "room-std",
        rate_plan_code: "rate-flex",
        checkin_date: ~D[2026-04-10],
        checkout_date: ~D[2026-04-11],
        traveler_count: 1,
        contact_name: "李四",
        contact_phone: "13900139000",
        total_amount: Decimal.new("100"),
        points_to_use: 1_000
      }
    }
  end
end
