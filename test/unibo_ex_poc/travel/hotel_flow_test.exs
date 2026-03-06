defmodule UniboExPoc.Travel.HotelFlowTest do
  use ExUnit.Case, async: true

  alias UniboExPoc.TravelStack.HotelFlow
  alias UniboExPoc.Travel.Travel.TravelFulfillment
  alias UniboExPoc.Travel.Travel.TravelOrder

  test "hotel 最小闭环可以从 quote 走到 booking confirmed" do
    input = %{
      context: %{
        user_id: "user-1",
        member_id: "member-1",
        enterprise_id: "ent-1",
        current_shop_id: "shop-1",
        request_id: "req-1"
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
        visible_enterprise_ids: ["ent-1"],
        allowed_product_types: [:hotel]
      },
      order: %{
        order_no: "travel-001",
        supplier_code: "jd-hotel",
        hotel_code: "hotel-001",
        room_type_code: "room-std",
        rate_plan_code: "rate-flex",
        checkin_date: ~D[2026-03-10],
        checkout_date: ~D[2026-03-11],
        traveler_count: 1,
        contact_name: "张三",
        contact_phone: "13800138000",
        total_amount: Decimal.new("100"),
        points_to_use: 1000
      }
    }

    assert {:ok, result} = HotelFlow.book(input, available_points: 1000, payment_method: :mixed)

    assert result.order.resource_module == TravelOrder
    assert result.order.status == :booked
    assert result.order.payment_status == :paid
    assert result.fulfillment.resource_module == TravelFulfillment
    assert result.fulfillment.status == :confirmed
    assert result.supplier_request.supplier_code == "jd-hotel"
    assert result.supplier_request.member_id == "member-1"
    assert Map.has_key?(result.supplier_request.supplier_payload, :supplier_hotel_id)
  end
end
