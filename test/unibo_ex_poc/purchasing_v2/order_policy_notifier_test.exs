defmodule UniboExPoc.PurchasingV2.OrderPolicyNotifierTest do
  use UniboExPoc.DataCase, async: false

  alias UniboExPoc.PurchasingV2
  alias UniboExPoc.PurchasingV2.Actor

  test "create 权限：buyer/admin 可创建，viewer 被拒绝" do
    supplier = create_supplier!(:active)

    params = %{
      order_name: "V2-PO-1",
      supplier_id: supplier.id,
      cost_amount: Decimal.new("100"),
      sell_amount: Decimal.new("130"),
      items: []
    }

    viewer = actor(:viewer)

    assert {:error, %Ash.Error.Forbidden{}} =
             Ash.create(PurchasingV2.Order, params, action: :create, actor: viewer)

    buyer = actor(:buyer)

    assert {:ok, order} =
             Ash.create(PurchasingV2.Order, params, action: :create, actor: buyer)

    assert order.created_by_id == buyer.id
  end

  test "update 权限：非创建人 buyer 不能更新，admin 可以" do
    supplier = create_supplier!(:active)
    creator = actor(:buyer)

    {:ok, order} =
      Ash.create(
        PurchasingV2.Order,
        %{order_name: "V2-PO-2", supplier_id: supplier.id, items: []},
        action: :create,
        actor: creator
      )

    other_buyer = actor(:buyer)

    assert {:error, %Ash.Error.Forbidden{}} =
             Ash.update(order, %{}, action: :submit, actor: other_buyer)

    admin = actor(:admin)
    assert {:ok, updated} = Ash.update(order, %{}, action: :submit, actor: admin)
    assert updated.status == :submitted
  end

  test "submit/approve/reject 会广播对应 topic" do
    supplier = create_supplier!(:active)
    creator = actor(:buyer)
    admin = actor(:admin)

    Phoenix.PubSub.subscribe(UniboExPoc.PubSub, "purchasing.order.submitted")
    Phoenix.PubSub.subscribe(UniboExPoc.PubSub, "purchasing.order.approved")
    Phoenix.PubSub.subscribe(UniboExPoc.PubSub, "purchasing.order.rejected")

    {:ok, order} =
      Ash.create(
        PurchasingV2.Order,
        %{order_name: "V2-PO-3", supplier_id: supplier.id, items: []},
        action: :create,
        actor: creator
      )

    {:ok, order} = Ash.update(order, %{}, action: :submit, actor: creator)
    assert_receive {:submit, submitted_data}
    assert submitted_data.id == order.id

    {:ok, order} = Ash.update(order, %{}, action: :approve, actor: admin)
    assert_receive {:approve, approved_data}
    assert approved_data.id == order.id

    {:ok, _order} = Ash.update(order, %{}, action: :reject, actor: admin)
    assert_receive {:reject, rejected_data}
    assert rejected_data.id == order.id
  end

  test "定制逻辑：供应商 active 校验 + emergency_approve + margin_rate" do
    inactive_supplier = create_supplier!(:inactive)

    assert {:error, error} =
             Ash.create(
               PurchasingV2.Order,
               %{order_name: "V2-PO-4", supplier_id: inactive_supplier.id, items: []},
               action: :create,
               actor: actor(:buyer)
             )

    assert Exception.message(error) =~ "供应商状态必须为 active"

    active_supplier = create_supplier!(:active)
    creator = actor(:buyer)

    {:ok, order} =
      Ash.create(
        PurchasingV2.Order,
        %{
          order_name: "V2-PO-5",
          supplier_id: active_supplier.id,
          cost_amount: Decimal.new("100"),
          sell_amount: Decimal.new("130"),
          items: []
        },
        action: :create,
        actor: creator
      )

    assert {:ok, emergency} = Ash.update(order, %{}, action: :emergency_approve, actor: creator)
    assert emergency.status == :approved

    loaded = Ash.load!(emergency, :margin_rate, actor: creator)
    assert Decimal.eq?(loaded.margin_rate, Decimal.new("0.3"))
  end

  defp create_supplier!(status) do
    {:ok, supplier} =
      Ash.create(
        PurchasingV2.Party,
        %{name: "供应商-#{status}", status: status, role: :supplier},
        action: :create,
        authorize?: false
      )

    supplier
  end

  defp actor(role) do
    %Actor{id: Ecto.UUID.generate(), role: role}
  end
end
