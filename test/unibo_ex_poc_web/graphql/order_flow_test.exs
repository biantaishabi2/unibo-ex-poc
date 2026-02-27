defmodule UniboExPocWeb.Graphql.OrderFlowTest do
  use UniboExPocWeb.ConnCase, async: false

  test "GraphQL 创建订单并完成状态流转", %{conn: conn} do
    create_party = """
    mutation CreateParty($input: CreatePartyInput!) {
      createParty(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    create_party_resp =
      graphql(conn, create_party, %{
        "input" => %{
          "partyType" => "party_group",
          "name" => "供应商A",
          "role" => "supplier"
        }
      })

    assert [] == get_in(create_party_resp, ["data", "createParty", "errors"])
    supplier_id = get_in(create_party_resp, ["data", "createParty", "result", "id"])
    assert is_binary(supplier_id)

    create_product = """
    mutation CreateProduct($input: CreateProductInput!) {
      createProduct(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    create_product_resp =
      graphql(conn, create_product, %{
        "input" => %{
          "internalName" => "SKU-001",
          "productName" => "测试产品"
        }
      })

    assert [] == get_in(create_product_resp, ["data", "createProduct", "errors"])
    product_id = get_in(create_product_resp, ["data", "createProduct", "result", "id"])
    assert is_binary(product_id)

    create_order = """
    mutation CreateOrder($input: CreateOrderInput!) {
      createOrder(input: $input) {
        result {
          id
          status
          items {
            id
            seqId
            quantity
            unitPrice
            subtotal
          }
        }
        errors { message fields }
      }
    }
    """

    create_order_resp =
      graphql(conn, create_order, %{
        "input" => %{
          "orderName" => "PO-001",
          "supplierId" => supplier_id,
          "items" => [
            %{
              "seqId" => 1,
              "quantity" => "2",
              "unitPrice" => "10.50",
              "productId" => product_id
            }
          ]
        }
      })

    assert [] == get_in(create_order_resp, ["data", "createOrder", "errors"])
    order_id = get_in(create_order_resp, ["data", "createOrder", "result", "id"])
    assert is_binary(order_id)
    assert "created" == get_in(create_order_resp, ["data", "createOrder", "result", "status"])
    assert 1 == get_in(create_order_resp, ["data", "createOrder", "result", "items"]) |> length()
    item_id = get_in(create_order_resp, ["data", "createOrder", "result", "items", Access.at(0), "id"])

    create_subtotal =
      get_in(create_order_resp, ["data", "createOrder", "result", "items", Access.at(0), "subtotal"])

    assert Decimal.eq?(Decimal.new(create_subtotal), Decimal.new("21"))

    list_orders = """
    query {
      listOrders(first: 20) {
        results { id }
      }
    }
    """

    list_orders_resp = graphql(conn, list_orders)
    order_ids = get_in(list_orders_resp, ["data", "listOrders", "results"]) |> Enum.map(& &1["id"])
    assert order_id in order_ids

    update_order = """
    mutation UpdateOrder($id: ID!, $input: UpdateOrderInput) {
      updateOrder(id: $id, input: $input) {
        result {
          id
          items {
            id
            quantity
            unitPrice
            subtotal
          }
        }
        errors { message fields }
      }
    }
    """

    update_resp =
      graphql(conn, update_order, %{
        "id" => order_id,
        "input" => %{
          "items" => [
            %{
              "id" => item_id,
              "quantity" => "3",
              "unitPrice" => "12.00"
            }
          ]
        }
      })

    assert [] == get_in(update_resp, ["data", "updateOrder", "errors"])

    update_subtotal =
      get_in(update_resp, ["data", "updateOrder", "result", "items", Access.at(0), "subtotal"])

    assert Decimal.eq?(Decimal.new(update_subtotal), Decimal.new("36"))

    approve_order = """
    mutation ApproveOrder($id: ID!) {
      approveOrder(id: $id) {
        result { id }
        errors { message fields }
      }
    }
    """

    approve_resp = graphql(conn, approve_order, %{"id" => order_id})
    assert [] == get_in(approve_resp, ["data", "approveOrder", "errors"])

    complete_order = """
    mutation CompleteOrder($id: ID!) {
      completeOrder(id: $id) {
        result { id }
        errors { message fields }
      }
    }
    """

    complete_resp = graphql(conn, complete_order, %{"id" => order_id})
    assert [] == get_in(complete_resp, ["data", "completeOrder", "errors"])

    cancel_order = """
    mutation CancelOrder($id: ID!) {
      cancelOrder(id: $id) {
        result { id }
        errors { message fields }
      }
    }
    """

    cancel_resp = graphql(conn, cancel_order, %{"id" => order_id})
    assert is_nil(get_in(cancel_resp, ["data", "cancelOrder", "result"]))
    assert [_ | _] = get_in(cancel_resp, ["data", "cancelOrder", "errors"])
  end

  test "GraphQL 创建订单缺少 supplierId 会失败", %{conn: conn} do
    mutation = """
    mutation {
      createOrder(input: {orderName: "PO-no-supplier"}) {
        result { id }
        errors { message fields }
      }
    }
    """

    resp = graphql(conn, mutation)
    assert [_ | _] = resp["errors"]
  end

  test "GraphQL 创建空行项订单也可成功", %{conn: conn} do
    create_party = """
    mutation CreateParty($input: CreatePartyInput!) {
      createParty(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    create_party_resp =
      graphql(conn, create_party, %{
        "input" => %{
          "partyType" => "party_group",
          "name" => "空行项供应商",
          "role" => "supplier"
        }
      })

    supplier_id = get_in(create_party_resp, ["data", "createParty", "result", "id"])

    mutation = """
    mutation CreateOrder($input: CreateOrderInput!) {
      createOrder(input: $input) {
        result { id status items { id } }
        errors { message fields }
      }
    }
    """

    resp =
      graphql(conn, mutation, %{
        "input" => %{
          "orderName" => "PO-empty-items",
          "supplierId" => supplier_id,
          "items" => []
        }
      })

    assert [] == get_in(resp, ["data", "createOrder", "errors"])
    assert "created" == get_in(resp, ["data", "createOrder", "result", "status"])
    assert [] == get_in(resp, ["data", "createOrder", "result", "items"])
  end

  test "GraphQL 未审批订单不能直接完成", %{conn: conn} do
    create_party = """
    mutation CreateParty($input: CreatePartyInput!) {
      createParty(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    supplier_resp =
      graphql(conn, create_party, %{
        "input" => %{
          "partyType" => "party_group",
          "name" => "审批校验供应商",
          "role" => "supplier"
        }
      })

    supplier_id = get_in(supplier_resp, ["data", "createParty", "result", "id"])

    create_order = """
    mutation CreateOrder($input: CreateOrderInput!) {
      createOrder(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    order_resp =
      graphql(conn, create_order, %{
        "input" => %{
          "orderName" => "PO-not-approved",
          "supplierId" => supplier_id,
          "items" => []
        }
      })

    order_id = get_in(order_resp, ["data", "createOrder", "result", "id"])

    complete_order = """
    mutation CompleteOrder($id: ID!) {
      completeOrder(id: $id) {
        result { id }
        errors { message fields }
      }
    }
    """

    complete_resp = graphql(conn, complete_order, %{"id" => order_id})
    assert is_nil(get_in(complete_resp, ["data", "completeOrder", "result"]))
    assert [_ | _] = get_in(complete_resp, ["data", "completeOrder", "errors"])
  end

  test "GraphQL 同一订单重复 seqId 的行项应失败", %{conn: conn} do
    create_party = """
    mutation CreateParty($input: CreatePartyInput!) {
      createParty(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    supplier_resp =
      graphql(conn, create_party, %{
        "input" => %{
          "partyType" => "party_group",
          "name" => "重复行项供应商",
          "role" => "supplier"
        }
      })

    supplier_id = get_in(supplier_resp, ["data", "createParty", "result", "id"])

    create_product = """
    mutation CreateProduct($input: CreateProductInput!) {
      createProduct(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    product_resp =
      graphql(conn, create_product, %{
        "input" => %{
          "internalName" => "SKU-DUP-SEQ",
          "productName" => "重复序号测试产品"
        }
      })

    product_id = get_in(product_resp, ["data", "createProduct", "result", "id"])

    create_order = """
    mutation CreateOrder($input: CreateOrderInput!) {
      createOrder(input: $input) {
        result { id }
        errors { message fields }
      }
    }
    """

    order_resp =
      graphql(conn, create_order, %{
        "input" => %{
          "orderName" => "PO-dup-seq",
          "supplierId" => supplier_id,
          "items" => [
            %{"seqId" => 1, "quantity" => "1", "unitPrice" => "10.00", "productId" => product_id},
            %{"seqId" => 1, "quantity" => "2", "unitPrice" => "20.00", "productId" => product_id}
          ]
        }
      })

    assert is_nil(get_in(order_resp, ["data", "createOrder", "result"]))
    assert [_ | _] = get_in(order_resp, ["data", "createOrder", "errors"])
  end

  defp graphql(conn, query, variables \\ %{}) do
    conn
    |> post("/api/graphql", %{query: query, variables: variables})
    |> json_response(200)
  end
end
