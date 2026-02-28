defmodule UniboExPocWeb.Graphql.OrderV3FlowTest do
  use UniboExPocWeb.ConnCase, async: false

  test "GraphQL V3：金额分级审批与风险供应商拦截" do
    buyer_id = Ecto.UUID.generate()
    admin_id = Ecto.UUID.generate()
    viewer_id = Ecto.UUID.generate()

    create_party = """
    mutation CreatePartyV3($input: CreatePartyV3Input!) {
      createPartyV3(input: $input) {
        result { id name status riskLevel isBlocked }
        errors { message fields }
      }
    }
    """

    high_risk_resp =
      graphql(
        build_conn(),
        create_party,
        %{
          "input" => %{
            "name" => "高风险供应商",
            "status" => "active",
            "riskLevel" => "high",
            "isBlocked" => false
          }
        },
        actor_id: admin_id,
        actor_role: "admin"
      )

    high_risk_supplier_id = get_in(high_risk_resp, ["data", "createPartyV3", "result", "id"])

    low_risk_resp =
      graphql(
        build_conn(),
        create_party,
        %{
          "input" => %{
            "name" => "低风险供应商",
            "status" => "active",
            "riskLevel" => "low",
            "isBlocked" => false
          }
        },
        actor_id: admin_id,
        actor_role: "admin"
      )

    low_risk_supplier_id = get_in(low_risk_resp, ["data", "createPartyV3", "result", "id"])

    create_order = """
    mutation CreateOrderV3($input: CreateOrderV3Input!) {
      createOrderV3(input: $input) {
        result { id status createdById totalAmount }
        errors { message fields }
      }
    }
    """

    # 高风险供应商：创建失败
    blocked_resp =
      graphql(
        build_conn(),
        create_order,
        %{
          "input" => %{
            "orderName" => "V3-risk-order",
            "totalAmount" => "5000",
            "supplierId" => high_risk_supplier_id
          }
        },
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    assert is_nil(get_in(blocked_resp, ["data", "createOrderV3", "result"]))
    assert [%{"message" => message}] = get_in(blocked_resp, ["data", "createOrderV3", "errors"])
    assert message =~ "风险等级过高"

    # viewer：创建失败
    viewer_resp =
      graphql(
        build_conn(),
        create_order,
        %{
          "input" => %{
            "orderName" => "V3-viewer-order",
            "totalAmount" => "5000",
            "supplierId" => low_risk_supplier_id
          }
        },
        actor_id: viewer_id,
        actor_role: "viewer"
      )

    assert is_nil(get_in(viewer_resp, ["data", "createOrderV3", "result"]))

    assert [%{"message" => "forbidden"}] =
             get_in(viewer_resp, ["data", "createOrderV3", "errors"])

    # buyer：小额单正常审批
    small_resp =
      graphql(
        build_conn(),
        create_order,
        %{
          "input" => %{
            "orderName" => "V3-small-order",
            "totalAmount" => "50000",
            "supplierId" => low_risk_supplier_id
          }
        },
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    small_order_id = get_in(small_resp, ["data", "createOrderV3", "result", "id"])
    assert buyer_id == get_in(small_resp, ["data", "createOrderV3", "result", "createdById"])

    submit_order = """
    mutation SubmitOrderV3($id: ID!) {
      submitOrderV3(id: $id) {
        result { id status }
        errors { message fields }
      }
    }
    """

    submit_small_resp =
      graphql(build_conn(), submit_order, %{"id" => small_order_id},
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    assert "submitted" == get_in(submit_small_resp, ["data", "submitOrderV3", "result", "status"])

    approve_order = """
    mutation ApproveOrderV3($id: ID!) {
      approveOrderV3(id: $id) {
        result { id status }
        errors { message fields }
      }
    }
    """

    approve_small_resp =
      graphql(build_conn(), approve_order, %{"id" => small_order_id},
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    assert "approved" ==
             get_in(approve_small_resp, ["data", "approveOrderV3", "result", "status"])

    # buyer：大额单普通审批被拦截
    large_resp =
      graphql(
        build_conn(),
        create_order,
        %{
          "input" => %{
            "orderName" => "V3-large-order",
            "totalAmount" => "100000",
            "supplierId" => low_risk_supplier_id
          }
        },
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    large_order_id = get_in(large_resp, ["data", "createOrderV3", "result", "id"])

    submit_large_resp =
      graphql(build_conn(), submit_order, %{"id" => large_order_id},
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    assert "submitted" == get_in(submit_large_resp, ["data", "submitOrderV3", "result", "status"])

    approve_large_resp =
      graphql(build_conn(), approve_order, %{"id" => large_order_id},
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    assert is_nil(get_in(approve_large_resp, ["data", "approveOrderV3", "result"]))

    assert [%{"message" => approve_err}] =
             get_in(approve_large_resp, ["data", "approveOrderV3", "errors"])

    assert approve_err =~ "需走高级审批"

    senior_approve = """
    mutation SeniorApproveOrderV3($id: ID!) {
      seniorApproveOrderV3(id: $id) {
        result { id status }
        errors { message fields }
      }
    }
    """

    senior_by_buyer_resp =
      graphql(build_conn(), senior_approve, %{"id" => large_order_id},
        actor_id: buyer_id,
        actor_role: "buyer"
      )

    assert is_nil(get_in(senior_by_buyer_resp, ["data", "seniorApproveOrderV3", "result"]))

    assert [%{"message" => senior_err}] =
             get_in(senior_by_buyer_resp, ["data", "seniorApproveOrderV3", "errors"])

    assert senior_err =~ "仅采购主管可执行高级审批"

    senior_by_admin_resp =
      graphql(build_conn(), senior_approve, %{"id" => large_order_id},
        actor_id: admin_id,
        actor_role: "admin"
      )

    assert "approved" ==
             get_in(senior_by_admin_resp, ["data", "seniorApproveOrderV3", "result", "status"])
  end

  defp graphql(conn, query, variables, actor_opts) do
    conn
    |> put_req_header("x-actor-id", Keyword.fetch!(actor_opts, :actor_id))
    |> put_req_header("x-actor-role", Keyword.fetch!(actor_opts, :actor_role))
    |> post("/api/graphql", %{query: query, variables: variables})
    |> json_response(200)
  end
end
