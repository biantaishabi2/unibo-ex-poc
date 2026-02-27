defmodule UniboExPocWeb.Purchasing.OrderLiveTest do
  use UniboExPocWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias UniboExPoc.Purchasing.{Order, Party}

  test "订单页面可创建新订单并展示在列表中", %{conn: conn} do
    supplier = create_supplier!()

    {:ok, view, html} = live(conn, "/purchasing/orders")
    assert html =~ "采购订单"

    view
    |> form("#order-form", order: %{"order_name" => "PO-LV-001", "supplier_id" => supplier.id})
    |> render_submit()

    rendered = render(view)
    assert rendered =~ "创建成功"
    assert rendered =~ "PO-LV-001"

    orders =
      Order
      |> Ash.Query.for_read(:read)
      |> Ash.read!(domain: UniboExPoc.Purchasing)

    assert Enum.any?(orders, &(&1.order_name == "PO-LV-001"))
  end

  test "未选择供应商时页面显示错误", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/purchasing/orders")

    view
    |> form("#order-form", order: %{"order_name" => "PO-LV-ERR", "supplier_id" => ""})
    |> render_submit()

    assert render(view) =~ "必须选择供应商"
  end

  defp create_supplier! do
    Party
    |> Ash.Changeset.for_create(:create, %{
      party_type: :party_group,
      name: "LiveView 供应商",
      role: :supplier
    })
    |> Ash.create!(domain: UniboExPoc.Purchasing)
  end
end
