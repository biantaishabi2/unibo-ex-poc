defmodule UniboExPoc.Travel.HotelFlowTest do
  use ExUnit.Case, async: true

  alias Travel.TestSupport.FakeShopTransport
  alias Travel.TravelStack.HotelFlow
  alias UniboExPoc.Travel.TravelFulfillment
  alias UniboExPoc.Travel.TravelOrder
  alias Travel.TravelHost.ShopBridgeClient

  test "HotelFlow 仅作为测试辅助时，hotel 闭环可通过 DefaultBridge 跑通" do
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

  test "hotel flow 接入 ShopBridgeClient 和 fake transport 后仍可跑通" do
    input = %{
      context: %{
        user_id: "user-2",
        member_id: "member-2",
        enterprise_id: "ent-2",
        current_shop_id: "shop-2",
        request_id: "req-2"
      },
      host_config: %{
        travel_enabled: true,
        points_enabled: true
      },
      payment: %{
        cashier: "shop-app"
      },
      order: %{
        order_no: "travel-002",
        supplier_code: "jd-hotel",
        hotel_code: "hotel-002",
        room_type_code: "room-deluxe",
        rate_plan_code: "rate-flex",
        checkin_date: ~D[2026-03-12],
        checkout_date: ~D[2026-03-13],
        traveler_count: 2,
        contact_name: "李四",
        contact_phone: "13900139000",
        total_amount: Decimal.new("120.00"),
        points_to_use: 500
      }
    }

    responses = %{
      resolve_context:
        {:ok,
         %{
           caller_context: %{
             user_id: "user-2",
             member_id: "member-2",
             enterprise_id: "ent-2",
             current_shop_id: "shop-2",
             request_id: "req-2",
             roles: ["cashier"]
           }
         }},
      quote: fn payload ->
        assert payload.caller_context.member_id == "member-2"
        assert payload.quote_request.available_points == 500
        assert payload.order["order_no"] == "travel-002"

        {:ok,
         %{
           eligibility_or_quote: %{
             allowed: true,
             product_type: "hotel",
             travel_enabled: true,
             points_enabled: true,
             mixed_payment_enabled: true,
             cash_payment_enabled: true,
             available_points: 500,
             points_requested: 500,
             points_sufficient: true,
             points_deduction_amount: "5.00",
             payable_amount: "115.00",
             recommended_payment_method: "mixed"
           }
         }}
      end,
      execute_payment: fn payload ->
        assert payload.payment_request.method == "mixed"
        assert payload.payment_request.metadata.cashier == "shop-app"

        {:ok,
         %{
           payment_execution: %{
             status: "approved",
             method: "mixed",
             external_ref: "pay-002",
             points_used: 500,
             points_deduction_amount: "5.00",
             cash_amount: "115.00"
           }
         }}
      end
    }

    assert {:ok, result} =
             HotelFlow.book(input,
               available_points: 500,
               payment_method: :mixed,
               bridge: ShopBridgeClient,
               bridge_opts: [
                 transport: FakeShopTransport,
                 transport_opts: [responses: responses]
               ]
             )

    assert result.context.current_shop_id == "shop-2"
    assert result.quote.allowed?
    assert result.payment.status == :approved
    assert result.order.resource_module == TravelOrder
    assert result.order.supplier_order_ref == "hotel-booking-travel-002"
    assert result.fulfillment.resource_module == TravelFulfillment
    assert result.fulfillment.voucher_or_ticket_ref == "voucher-travel-002"
  end
end
