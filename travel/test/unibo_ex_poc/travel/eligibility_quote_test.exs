defmodule UniboExPoc.Travel.EligibilityQuoteTest do
  use ExUnit.Case, async: true

  alias Travel.TravelHost.CallerContext
  alias Travel.TravelHost.EligibilityOrQuote
  alias Travel.TravelHost.HostConfig
  alias Travel.TravelHost.PaymentExecution

  test "宿主关闭 travel 时，quote 会直接拒绝" do
    {:ok, context} =
      CallerContext.normalize(%{
        user_id: "user-1",
        member_id: "member-1",
        enterprise_id: "ent-1",
        current_shop_id: "shop-1",
        request_id: "req-1"
      })

    config = HostConfig.new(%{travel_enabled: false, cash_payment_enabled: true})

    quote =
      EligibilityOrQuote.build(
        %{product_type: :hotel, total_amount: Decimal.new("500"), points_to_use: 100},
        context,
        config,
        available_points: 200
      )

    refute quote.allowed?
    assert quote.reason == :travel_disabled
  end

  test "宿主开启 mixed payment 时，quote 会返回 mixed 建议" do
    {:ok, context} =
      CallerContext.normalize(%{
        user_id: "user-1",
        member_id: "member-1",
        enterprise_id: "ent-1",
        current_shop_id: "shop-1",
        request_id: "req-1"
      })

    config =
      HostConfig.new(%{
        travel_enabled: true,
        points_enabled: true,
        mixed_payment_enabled: true,
        cash_payment_enabled: true,
        points_exchange_rate: "0.01",
        min_points_to_use: 100,
        max_points_deduction_amount: "20",
        visible_enterprise_ids: ["ent-1"]
      })

    quote =
      EligibilityOrQuote.build(
        %{product_type: :hotel, total_amount: Decimal.new("100"), points_to_use: 1000},
        context,
        config,
        available_points: 1000
      )

    assert quote.allowed?
    assert quote.recommended_payment_method == :mixed
    assert Decimal.equal?(quote.points_deduction_amount, Decimal.new("10"))
    assert Decimal.equal?(quote.payable_amount, Decimal.new("90"))

    assert {:ok, payment} = PaymentExecution.execute(:mixed, quote, external_ref: "pay-1")
    assert payment.status == :approved
    assert payment.method == :mixed
    assert Decimal.equal?(payment.cash_amount, Decimal.new("90"))
  end
end
