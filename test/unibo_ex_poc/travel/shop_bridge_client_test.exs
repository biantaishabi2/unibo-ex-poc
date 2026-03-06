defmodule UniboExPoc.Travel.ShopBridgeClientTest do
  use ExUnit.Case, async: true

  alias UniboExPoc.TestSupport.FakeShopTransport
  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.ShopBridgeClient

  test "resolve_context 可以把宿主 bridge 返回映射成 CallerContext" do
    assert {:ok, context} =
             ShopBridgeClient.resolve_context(
               %{"x-user-id" => "user-1"},
               transport: FakeShopTransport,
               transport_opts: [
                 responses: %{
                   resolve_context:
                     {:ok,
                      %{
                        caller_context: %{
                          "user_id" => "user-1",
                          "member_id" => "member-1",
                          "enterprise_id" => "ent-1",
                          "current_shop_id" => "shop-1",
                          "request_id" => "req-1",
                          "roles" => ["shop_admin"]
                        }
                      }}
                 }
               ]
             )

    assert context.user_id == "user-1"
    assert context.member_id == "member-1"
    assert context.roles == ["shop_admin"]
  end

  test "quote 成功时会把 shop bridge 响应映射成 EligibilityOrQuote" do
    context = caller_context()

    assert {:ok, quote} =
             ShopBridgeClient.quote(
               order_attrs(),
               context,
               transport: FakeShopTransport,
               transport_opts: [
                 test_pid: self(),
                 responses: %{
                   quote: fn payload ->
                     assert payload.caller_context.member_id == "member-1"
                     assert payload.quote_request.available_points == 1_000
                     assert payload.order["order_no"] == "travel-001"

                     {:ok,
                      %{
                        eligibility_or_quote: %{
                          "allowed" => true,
                          "product_type" => "hotel",
                          "travel_enabled" => true,
                          "points_enabled" => true,
                          "mixed_payment_enabled" => true,
                          "cash_payment_enabled" => true,
                          "available_points" => 1_000,
                          "points_requested" => 800,
                          "points_sufficient" => true,
                          "points_deduction_amount" => "8.00",
                          "payable_amount" => "92.00",
                          "recommended_payment_method" => "mixed"
                        }
                      }}
                   end
                 }
               ],
               available_points: 1_000,
               host_config: %{travel_enabled: true}
             )

    assert_received {:fake_shop_transport, :quote, _payload}
    assert quote.allowed?
    assert quote.product_type == :hotel
    assert quote.recommended_payment_method == :mixed
    assert Decimal.equal?(quote.payable_amount, Decimal.new("92.00"))
  end

  test "quote 拒绝时会保留宿主返回原因" do
    context = caller_context()

    assert {:ok, quote} =
             ShopBridgeClient.quote(
               order_attrs(),
               context,
               transport: FakeShopTransport,
               transport_opts: [
                 responses: %{
                   quote:
                     {:ok,
                      %{
                        eligibility_or_quote: %{
                          "allowed" => false,
                          "reason" => "enterprise_not_visible",
                          "payable_amount" => "100.00"
                        }
                      }}
                 }
               ]
             )

    refute quote.allowed?
    assert quote.reason == :enterprise_not_visible
    assert Decimal.equal?(quote.payable_amount, Decimal.new("100.00"))
  end

  test "execute_payment 成功时会把 shop bridge 响应映射成 PaymentExecution" do
    quote = %UniboExPoc.TravelHost.EligibilityOrQuote{
      allowed?: true,
      product_type: :hotel,
      travel_enabled: true,
      points_enabled: true,
      mixed_payment_enabled: true,
      cash_payment_enabled: true,
      available_points: 1_000,
      points_requested: 800,
      points_sufficient: true,
      points_deduction_amount: Decimal.new("8.00"),
      payable_amount: Decimal.new("92.00"),
      recommended_payment_method: :mixed
    }

    assert {:ok, payment} =
             ShopBridgeClient.execute_payment(
               :mixed,
               quote,
               transport: FakeShopTransport,
               transport_opts: [
                 test_pid: self(),
                 responses: %{
                   execute_payment: fn payload ->
                     assert payload.payment_request.method == "mixed"
                     assert payload.payment_request.external_ref == "order-001"
                     assert payload.payment_request.metadata.payment_environment == "H5"
                     assert payload.payment_request.metadata.scene == "hotel_order"
                     assert payload.eligibility_or_quote.points_requested == 800

                     {:ok,
                      %{
                        payment_execution: %{
                          status: "approved",
                          method: "wechat",
                          external_ref: "pay-001",
                          points_used: 800,
                          points_deduction_amount: "8.00",
                          cash_amount: "92.00"
                        }
                      }}
                   end
                 }
               ],
               payment_request: %{
                 order_id: "order-001",
                 payment_environment: "H5",
                 scene: "hotel_order"
               }
             )

    assert_received {:fake_shop_transport, :execute_payment, _payload}
    assert payment.status == :approved
    assert payment.method == :cash
    assert payment.external_ref == "pay-001"
    assert payment.points_used == 800
    assert Decimal.equal?(payment.cash_amount, Decimal.new("92.00"))
  end

  defp caller_context do
    {:ok, context} =
      CallerContext.normalize(%{
        user_id: "user-1",
        member_id: "member-1",
        enterprise_id: "ent-1",
        current_shop_id: "shop-1",
        request_id: "req-1"
      })

    context
  end

  defp order_attrs do
    %{
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
      total_amount: Decimal.new("100.00"),
      points_to_use: 800,
      product_type: :hotel
    }
  end
end
