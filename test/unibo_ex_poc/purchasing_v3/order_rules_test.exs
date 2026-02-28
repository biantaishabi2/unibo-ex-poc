defmodule UniboExPoc.PurchasingV3.OrderRulesTest do
  use UniboExPoc.DataCase, async: false

  alias UniboExPoc.PurchasingV3
  alias UniboExPoc.PurchasingV3.Actor

  test "小额订单可走普通审批" do
    supplier = create_supplier!(:low, false)
    buyer = actor(:buyer)

    {:ok, order} =
      Ash.create(
        PurchasingV3.Order,
        %{order_name: "V3-small", total_amount: Decimal.new("50000"), supplier_id: supplier.id},
        action: :create,
        actor: buyer
      )

    assert order.status == :created
    assert order.created_by_id == buyer.id

    {:ok, order} = Ash.update(order, %{}, action: :submit, actor: buyer)
    assert order.status == :submitted

    {:ok, order} = Ash.update(order, %{}, action: :approve, actor: buyer)
    assert order.status == :approved
  end

  test "高风险供应商会被拦截" do
    supplier = create_supplier!(:high, false)

    assert {:error, error} =
             Ash.create(
               PurchasingV3.Order,
               %{
                 order_name: "V3-risk-high",
                 total_amount: Decimal.new("1000"),
                 supplier_id: supplier.id
               },
               action: :create,
               actor: actor(:buyer)
             )

    assert Exception.message(error) =~ "供应商风险等级过高"
  end

  test "禁用供应商会被拦截" do
    supplier = create_supplier!(:low, true)

    assert {:error, error} =
             Ash.create(
               PurchasingV3.Order,
               %{
                 order_name: "V3-risk-blocked",
                 total_amount: Decimal.new("1000"),
                 supplier_id: supplier.id
               },
               action: :create,
               actor: actor(:buyer)
             )

    assert Exception.message(error) =~ "供应商已被禁用"
  end

  test "大额订单必须走高级审批" do
    supplier = create_supplier!(:low, false)
    buyer = actor(:buyer)

    {:ok, order} =
      Ash.create(
        PurchasingV3.Order,
        %{order_name: "V3-large", total_amount: Decimal.new("100000"), supplier_id: supplier.id},
        action: :create,
        actor: buyer
      )

    {:ok, order} = Ash.update(order, %{}, action: :submit, actor: buyer)

    assert {:error, error} = Ash.update(order, %{}, action: :approve, actor: buyer)
    assert Exception.message(error) =~ "需走高级审批"

    assert {:error, error} = Ash.update(order, %{}, action: :senior_approve, actor: buyer)
    assert Exception.message(error) =~ "仅采购主管可执行高级审批"

    {:ok, approved} = Ash.update(order, %{}, action: :senior_approve, actor: actor(:admin))
    assert approved.status == :approved
  end

  defp create_supplier!(risk_level, is_blocked) do
    {:ok, supplier} =
      Ash.create(
        PurchasingV3.Party,
        %{
          name: "供应商-#{risk_level}-#{is_blocked}",
          status: :active,
          risk_level: risk_level,
          is_blocked: is_blocked
        },
        action: :create,
        authorize?: false
      )

    supplier
  end

  defp actor(role) do
    %Actor{id: Ecto.UUID.generate(), role: role}
  end
end
