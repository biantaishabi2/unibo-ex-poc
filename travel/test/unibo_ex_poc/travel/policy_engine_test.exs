defmodule UniboExPoc.Travel.PolicyEngineTest do
  use ExUnit.Case, async: true

  alias UniboExPoc.Travel.PolicyEngine

  # NOTE: Since we don't have a running database in tests,
  # we test check_compliance and apply_strategy directly
  # (match_policy requires DB, tested via integration tests)

  describe "check_compliance/2" do
    test "无匹配策略 → 合规" do
      result = PolicyEngine.check_compliance(%{actual_amount: 1000}, nil)
      assert result.check_result == :compliant
      assert result.actual_amount == 1000
      assert is_nil(result.policy_amount)
    end

    test "金额未超标 → 合规" do
      policy = build_policy(max_amount: 2000, exceed_strategy: :require_approval)
      result = PolicyEngine.check_compliance(%{actual_amount: 1500}, policy)
      assert result.check_result == :compliant
      assert result.policy_amount == 2000
      assert result.actual_amount == 1500
      assert result.exceed_amount == 0
    end

    test "金额超标 → exceeded + 计算超标金额和比例" do
      policy = build_policy(max_amount: 1000, exceed_strategy: :require_approval)
      result = PolicyEngine.check_compliance(%{actual_amount: 1500}, policy)
      assert result.check_result == :exceeded
      assert result.exceed_amount == 500
      assert result.exceed_ratio == "50.0%"
      assert result.exceed_strategy == "require_approval"
    end

    test "personal_pay 策略计算个人支付金额" do
      policy = build_policy(
        max_amount: 1000,
        exceed_strategy: :personal_pay,
        personal_pay_ratio: 100
      )
      result = PolicyEngine.check_compliance(%{actual_amount: 1500}, policy)
      assert result.check_result == :exceeded
      assert result.personal_pay_amount == 500
    end

    test "personal_pay 策略 50% 比例" do
      policy = build_policy(
        max_amount: 1000,
        exceed_strategy: :personal_pay,
        personal_pay_ratio: 50
      )
      result = PolicyEngine.check_compliance(%{actual_amount: 1500}, policy)
      assert result.personal_pay_amount == 250
    end
  end

  describe "apply_strategy/1" do
    test "合规 → proceed" do
      assert {:ok, :proceed} = PolicyEngine.apply_strategy(%{check_result: :compliant})
    end

    test "超标 + block → error blocked" do
      assert {:error, :blocked} = PolicyEngine.apply_strategy(%{
        check_result: :exceeded,
        exceed_strategy: "block"
      })
    end

    test "超标 + require_reason → ok require_reason" do
      assert {:ok, :require_reason} = PolicyEngine.apply_strategy(%{
        check_result: :exceeded,
        exceed_strategy: "require_reason"
      })
    end

    test "超标 + require_approval → ok require_approval with check data" do
      check = %{check_result: :exceeded, exceed_strategy: "require_approval", exceed_amount: 500}
      assert {:ok, :require_approval, ^check} = PolicyEngine.apply_strategy(check)
    end

    test "超标 + personal_pay → ok personal_pay with amount" do
      check = %{
        check_result: :exceeded,
        exceed_strategy: "personal_pay",
        personal_pay_amount: 300
      }
      assert {:ok, :personal_pay, 300} = PolicyEngine.apply_strategy(check)
    end
  end

  # 构建测试用的 policy struct（不依赖数据库）
  defp build_policy(attrs) do
    defaults = %{
      id: "00000000-0000-0000-0000-000000000001",
      policy_name: "测试差旅标准",
      product_type: :flight,
      employee_level: nil,
      city_tier: nil,
      season: nil,
      max_amount: 2000,
      cabin_class_limit: "经济舱",
      hotel_star_limit: nil,
      exceed_strategy: :require_approval,
      personal_pay_ratio: nil,
      is_active: true,
      enterprise_id: nil
    }

    struct!(UniboExPoc.Travel.TravelPolicy, Map.merge(defaults, Map.new(attrs)))
  end
end
