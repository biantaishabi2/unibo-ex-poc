defmodule UniboExPoc.Travel.ApprovalModeFlowTest do
  use ExUnit.Case, async: false

  alias UniboExPoc.Travel.{TravelChangeOrder, TravelOrder, TravelRefundOrder}
  alias Ecto.Adapters.SQL

  setup do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(UniboExPoc.Repo, shared: false)
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end

  test "approval_mode none 时改签单可直接完成" do
    order = create_order!("CHANGE")

    change_order =
      TravelChangeOrder
      |> Ash.Changeset.for_create(:create, %{
        original_order_id: order.id,
        change_reason: "航班变更",
        price_difference: "120",
        change_fee: "50",
        new_offer_id: "offer-change-1",
        approval_mode: :none
      })
      |> Ash.create!(tenant: order.tenant_id)

    assert change_order.status == :pending
    assert change_order.approval_mode == :none

    completed =
      change_order
      |> Ash.Changeset.for_update(:complete_direct, %{})
      |> Ash.update!(tenant: order.tenant_id)

    assert completed.status == :completed
  end

  test "approval_mode none 时退票单可直接退款" do
    order = create_order!("REFUND")

    refund_order =
      TravelRefundOrder
      |> Ash.Changeset.for_create(:create, %{
        original_order_id: order.id,
        refund_reason: "行程取消",
        refund_fee: "20",
        refund_amount: "300",
        approval_mode: :none
      })
      |> Ash.create!(tenant: order.tenant_id)

    assert refund_order.status == :pending
    assert refund_order.approval_mode == :none

    refunded =
      refund_order
      |> Ash.Changeset.for_update(:refund_direct, %{})
      |> Ash.update!(tenant: order.tenant_id)

    assert refunded.status == :refunded
  end

  defp create_order!(suffix) do
    id = Ecto.UUID.generate()
    tenant_id = Ecto.UUID.generate()
    now = DateTime.utc_now()

    SQL.query!(
      UniboExPoc.Repo,
      """
      insert into travel_orders (
        id, tenant_id, order_no, product_type, contact_name, contact_phone,
        traveler_count, total_amount, points_to_use, points_deduction_amount,
        currency, status, change_status, waitlist_status, inserted_at, updated_at
      ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
      """,
      [
        Ecto.UUID.dump!(id),
        Ecto.UUID.dump!(tenant_id),
        "TEST-#{suffix}-#{System.unique_integer([:positive])}",
        "flight",
        "测试联系人",
        "13800000000",
        1,
        Decimal.new("1000"),
        0,
        Decimal.new("0"),
        "CNY",
        "draft",
        "none",
        "none",
        now,
        now
      ]
    )

    %TravelOrder{id: id, tenant_id: tenant_id}
  end
end
