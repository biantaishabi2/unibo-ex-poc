defmodule UniboExPoc.ManualVerifyIssue9 do
  @moduledoc false

  alias UniboExPoc.PurchasingV2.Actor
  alias UniboExPoc.Repo

  require Logger

  @create_party """
  mutation CreatePartyV3($input: CreatePartyV3Input!) {
    createPartyV3(input: $input) {
      result { id name status riskLevel isBlocked }
      errors { message fields }
    }
  }
  """

  @create_order """
  mutation CreateOrderV3($input: CreateOrderV3Input!) {
    createOrderV3(input: $input) {
      result { id status createdById totalAmount }
      errors { message fields }
    }
  }
  """

  @submit_order """
  mutation SubmitOrderV3($id: ID!) {
    submitOrderV3(id: $id) {
      result { id status }
      errors { message fields }
    }
  }
  """

  @approve_order """
  mutation ApproveOrderV3($id: ID!) {
    approveOrderV3(id: $id) {
      result { id status }
      errors { message fields }
    }
  }
  """

  @senior_approve_order """
  mutation SeniorApproveOrderV3($id: ID!) {
    seniorApproveOrderV3(id: $id) {
      result { id status }
      errors { message fields }
    }
  }
  """

  def run do
    Logger.configure(level: :error)
    reset_v3_tables!()

    admin = %Actor{id: Ecto.UUID.generate(), role: :admin}
    buyer = %Actor{id: Ecto.UUID.generate(), role: :buyer}

    high_supplier_resp =
      gql(@create_party, %{
        "input" => %{
          "name" => "手工验证-高风险供应商",
          "status" => "active",
          "riskLevel" => "high",
          "isBlocked" => false
        }
      }, admin)

    low_supplier_resp =
      gql(@create_party, %{
        "input" => %{
          "name" => "手工验证-低风险供应商",
          "status" => "active",
          "riskLevel" => "low",
          "isBlocked" => false
        }
      }, admin)

    high_supplier_id = get_in(high_supplier_resp, [:data, "createPartyV3", "result", "id"])
    low_supplier_id = get_in(low_supplier_resp, [:data, "createPartyV3", "result", "id"])

    # 规则1：供应商风险控制（正/反）
    rule1_positive =
      gql(@create_order, %{
        "input" => %{
          "orderName" => "ISSUE9-R1-POS",
          "totalAmount" => "5000",
          "supplierId" => low_supplier_id
        }
      }, buyer)

    rule1_negative =
      gql(@create_order, %{
        "input" => %{
          "orderName" => "ISSUE9-R1-NEG",
          "totalAmount" => "5000",
          "supplierId" => high_supplier_id
        }
      }, buyer)

    rule1_pos_order_id = get_in(rule1_positive, [:data, "createOrderV3", "result", "id"])

    # 规则2：状态流转约束（正/反）
    rule2_positive = gql(@submit_order, %{"id" => rule1_pos_order_id}, buyer)

    rule2_negative_seed =
      gql(@create_order, %{
        "input" => %{
          "orderName" => "ISSUE9-R2-NEG-SEED",
          "totalAmount" => "5000",
          "supplierId" => low_supplier_id
        }
      }, buyer)

    rule2_negative_order_id =
      get_in(rule2_negative_seed, [:data, "createOrderV3", "result", "id"])

    rule2_negative = gql(@approve_order, %{"id" => rule2_negative_order_id}, buyer)

    # 规则3：大额单高级审批（正/反）
    rule3_seed =
      gql(@create_order, %{
        "input" => %{
          "orderName" => "ISSUE9-R3-SEED",
          "totalAmount" => "100000",
          "supplierId" => low_supplier_id
        }
      }, buyer)

    rule3_order_id = get_in(rule3_seed, [:data, "createOrderV3", "result", "id"])
    _rule3_submit = gql(@submit_order, %{"id" => rule3_order_id}, buyer)

    rule3_negative = gql(@approve_order, %{"id" => rule3_order_id}, buyer)
    rule3_positive = gql(@senior_approve_order, %{"id" => rule3_order_id}, admin)

    report = %{
      meta: %{
        generated_at: DateTime.utc_now() |> DateTime.to_iso8601(),
        issue: 9
      },
      rules: [
        %{
          id: "rule-1",
          name: "风险供应商拦截",
          positive: scenario(
            "低风险供应商可下单",
            "创建成功并返回订单ID",
            rule1_positive,
            fn resp ->
              is_binary(get_in(resp, [:data, "createOrderV3", "result", "id"])) and
                is_nil(first_error_message(resp, "createOrderV3"))
            end
          ),
          negative: scenario(
            "高风险供应商禁止下单",
            "创建失败，错误包含“风险等级过高”",
            rule1_negative,
            fn resp ->
              is_nil(get_in(resp, [:data, "createOrderV3", "result"])) and
                String.contains?(
                  first_error_message(resp, "createOrderV3") || "",
                  "风险等级过高"
                )
            end
          )
        },
        %{
          id: "rule-2",
          name: "状态流转约束",
          positive: scenario(
            "created -> submitted",
            "提交成功，状态变为submitted",
            rule2_positive,
            fn resp -> get_in(resp, [:data, "submitOrderV3", "result", "status"]) == "submitted" end
          ),
          negative: scenario(
            "created 不能直接 approve",
            "审批失败，错误包含“只有已提交订单可以审批”",
            rule2_negative,
            fn resp ->
              is_nil(get_in(resp, [:data, "approveOrderV3", "result"])) and
                String.contains?(
                  first_error_message(resp, "approveOrderV3") || "",
                  "只有已提交订单可以审批"
                )
            end
          )
        },
        %{
          id: "rule-3",
          name: "大额单高级审批",
          positive: scenario(
            "admin 可执行 senior approve",
            "高级审批成功，状态变为approved",
            rule3_positive,
            fn resp ->
              get_in(resp, [:data, "seniorApproveOrderV3", "result", "status"]) == "approved"
            end
          ),
          negative: scenario(
            "buyer 不能普通审批大额单",
            "普通审批失败，错误包含“需走高级审批”",
            rule3_negative,
            fn resp ->
              is_nil(get_in(resp, [:data, "approveOrderV3", "result"])) and
                String.contains?(
                  first_error_message(resp, "approveOrderV3") || "",
                  "需走高级审批"
                )
            end
          )
        }
      ]
    }

    IO.puts(Jason.encode!(report, pretty: true))
  end

  defp scenario(title, expected, actual, pass_fun) do
    %{
      title: title,
      expected: expected,
      actual: actual,
      pass: pass_fun.(actual)
    }
  end

  defp gql(query, variables, actor) do
    case Absinthe.run(query, UniboExPocWeb.Schema, variables: variables, context: %{actor: actor}) do
      {:ok, response} -> response
      {:error, errors} -> %{"errors" => inspect(errors)}
    end
  end

  defp first_error_message(resp, field_name) do
    resp
    |> get_in([:data, field_name, "errors"])
    |> case do
      [%{"message" => message} | _] -> message
      _ -> nil
    end
  end

  defp reset_v3_tables! do
    Ecto.Adapters.SQL.query!(Repo, "TRUNCATE TABLE v3_orders, v3_parties RESTART IDENTITY CASCADE", [])
  end
end

UniboExPoc.ManualVerifyIssue9.run()
