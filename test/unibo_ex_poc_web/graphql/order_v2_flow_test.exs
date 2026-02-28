defmodule UniboExPocWeb.Graphql.OrderV2FlowTest do
  use UniboExPocWeb.ConnCase, async: false

  alias UniboExPoc.PurchasingV2

  test "GraphQL 透传 actor：viewer 无权创建，buyer 可创建并传入 created_by_id", %{conn: conn} do
    supplier = create_supplier!(:active)
    buyer_id = Ecto.UUID.generate()

    mutation = """
    mutation CreateOrderV2($input: CreateOrderV2Input!) {
      createOrderV2(input: $input) {
        result {
          id
          status
          createdById
        }
        errors { message fields }
      }
    }
    """

    # viewer 角色应被 policy 拒绝
    viewer_resp =
      graphql(
        conn,
        mutation,
        %{"input" => %{"orderName" => "GQL-V2-PO-1", "supplierId" => supplier.id, "items" => []}},
        actor_id: Ecto.UUID.generate(),
        actor_role: "viewer"
      )

    assert is_nil(get_in(viewer_resp, ["data", "createOrderV2", "result"]))
    assert [_ | _] = get_in(viewer_resp, ["data", "createOrderV2", "errors"])

    # buyer 角色可创建，且 created_by_id 来自 header actor
    buyer_resp =
      graphql(
        conn,
        mutation,
        %{"input" => %{"orderName" => "GQL-V2-PO-2", "supplierId" => supplier.id, "items" => []}},
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    assert [] == get_in(buyer_resp, ["data", "createOrderV2", "errors"])
    assert "created" == get_in(buyer_resp, ["data", "createOrderV2", "result", "status"])
    assert buyer_id == get_in(buyer_resp, ["data", "createOrderV2", "result", "createdById"])
  end

  defp create_supplier!(status) do
    {:ok, supplier} =
      Ash.create(
        PurchasingV2.Party,
        %{name: "GraphQL供应商", status: status, role: :supplier},
        action: :create,
        authorize?: false
      )

    supplier
  end

  defp graphql(conn, query, variables, actor_opts) do
    conn
    |> put_req_header("x-actor-id", Keyword.fetch!(actor_opts, :actor_id))
    |> put_req_header("x-actor-role", Keyword.fetch!(actor_opts, :actor_role))
    |> post("/api/graphql", %{query: query, variables: variables})
    |> json_response(200)
  end
end
