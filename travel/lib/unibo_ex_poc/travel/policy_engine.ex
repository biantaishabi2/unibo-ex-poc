defmodule UniboExPoc.Travel.PolicyEngine do
  @moduledoc """
  差标校验引擎 — 匹配差旅政策、校验合规性、执行超标策略
  """

  alias UniboExPoc.Travel.TravelPolicy

  @doc """
  按职级 + 城市等级 + 商品类型匹配最具体的 TravelPolicy。
  匹配优先级：完全匹配 > 部分匹配（有 employee_level）> 通用（无 employee_level）
  无匹配返回 nil。
  """
  @spec match_policy(String.t(), String.t(), String.t()) :: TravelPolicy.t() | nil
  def match_policy(product_type, employee_level, city_tier) do
    # 查询所有激活的策略，按匹配精确度排序
    # 1. 精确匹配: product_type + employee_level + city_tier
    # 2. 部分匹配: product_type + employee_level (city_tier 为 nil)
    # 3. 部分匹配: product_type + city_tier (employee_level 为 nil)
    # 4. 通用匹配: product_type only
    # 返回最精确的那个

    # NOTE: TravelPolicy 完整 Ash 资源由编译流水线生成（#101）。
    # 当前为 POC 占位实现，正式资源上线后替换为 Ash.Query.filter 查询：
    #
    #   TravelPolicy
    #   |> Ash.Query.filter(is_active == true)
    #   |> Ash.Query.filter(product_type == ^product_type)
    #   |> Ash.read!()
    #
    # 暂时返回空列表，使调用方走"无匹配策略"合规路径。
    policies = []

    find_best_match(policies, employee_level, city_tier)
  end

  defp find_best_match([], _employee_level, _city_tier), do: nil

  defp find_best_match(policies, employee_level, city_tier) do
    # 精确匹配优先
    Enum.find(policies, fn p ->
      p.employee_level == employee_level and p.city_tier == city_tier
    end)
    || Enum.find(policies, fn p ->
      p.employee_level == employee_level and is_nil(p.city_tier)
    end)
    || Enum.find(policies, fn p ->
      is_nil(p.employee_level) and p.city_tier == city_tier
    end)
    || Enum.find(policies, fn p ->
      is_nil(p.employee_level) and is_nil(p.city_tier)
    end)
  end

  @doc """
  对比实际金额与差标，生成校验结果。
  返回 TravelPolicyCheck 的属性 map（不持久化，由调用方决定是否保存）。
  """
  @spec check_compliance(map(), TravelPolicy.t() | nil) :: map()
  def check_compliance(order_params, nil) do
    # 无匹配策略 → 合规
    %{
      check_result: :compliant,
      policy_amount: nil,
      actual_amount: order_params[:actual_amount],
      exceed_amount: nil,
      exceed_ratio: nil,
      exceed_strategy: nil,
      approval_mode: nil,
      exceed_reason: nil,
      personal_pay_amount: nil
    }
  end

  def check_compliance(order_params, policy) do
    actual = order_params[:actual_amount] || 0
    limit = policy.max_amount || 0
    approval_mode = policy.approval_mode |> to_string()

    if actual <= limit do
      %{
        check_result: :compliant,
        policy_amount: limit,
        actual_amount: actual,
        exceed_amount: 0,
        exceed_ratio: "0%",
        exceed_strategy: to_string(policy.exceed_strategy),
        approval_mode: approval_mode,
        exceed_reason: nil,
        personal_pay_amount: nil
      }
    else
      exceed = actual - limit
      ratio = if limit > 0, do: Float.round(exceed / limit * 100, 1), else: 100.0

      personal_pay =
        case policy.exceed_strategy do
          :personal_pay ->
            pay_ratio = policy.personal_pay_ratio || 100
            round(exceed * pay_ratio / 100)

          _ ->
            nil
        end

      %{
        check_result: :exceeded,
        policy_amount: limit,
        actual_amount: actual,
        exceed_amount: exceed,
        exceed_ratio: "#{ratio}%",
        exceed_strategy: to_string(policy.exceed_strategy),
        approval_mode: approval_mode,
        exceed_reason: nil,
        personal_pay_amount: personal_pay
      }
    end
  end

  @doc """
  根据校验结果和超标策略，返回应执行的动作。
  返回值:
  - {:ok, :proceed} — 合规，直接下单
  - {:error, :blocked} — 拦截，不允许下单
  - {:ok, :require_reason} — 需要填写超标原因
  - {:ok, :require_approval, check_attrs} — 需要审批
  - {:ok, :personal_pay, personal_pay_amount} — 个人支付差额
  """
  @spec apply_strategy(map()) :: {:ok, atom()} | {:ok, atom(), any()} | {:error, atom()}
  def apply_strategy(%{check_result: :compliant}), do: {:ok, :proceed}

  def apply_strategy(%{check_result: :exceeded, exceed_strategy: "block"}) do
    {:error, :blocked}
  end

  def apply_strategy(%{check_result: :exceeded, exceed_strategy: "require_reason"}) do
    {:ok, :require_reason}
  end

  def apply_strategy(%{
        check_result: :exceeded,
        exceed_strategy: "require_approval",
        approval_mode: "none"
      }) do
    {:ok, :proceed}
  end

  def apply_strategy(%{check_result: :exceeded, exceed_strategy: "require_approval"} = check) do
    {:ok, :require_approval, check}
  end

  def apply_strategy(%{check_result: :exceeded, exceed_strategy: "personal_pay"} = check) do
    {:ok, :personal_pay, check.personal_pay_amount}
  end

  def apply_strategy(%{check_result: :exceeded} = check) do
    {:error, {:unknown_strategy, check[:exceed_strategy]}}
  end

  @doc """
  完整校验流程：匹配策略 → 校验合规 → 确定策略动作
  """
  @spec check(map()) :: {{:ok, atom()} | {:ok, atom(), any()} | {:error, atom()}, map()}
  def check(order_params) do
    product_type = order_params[:product_type] || "flight"
    employee_level = order_params[:employee_level]
    city_tier = order_params[:city_tier]

    policy = match_policy(product_type, employee_level, city_tier)
    check_result = check_compliance(order_params, policy)

    # 附带 policy_id 和 order_id 用于后续保存
    check_with_ids =
      check_result
      |> Map.put(:policy_id, if(policy, do: policy.id))
      |> Map.put(:order_id, order_params[:order_id])

    {apply_strategy(check_result), check_with_ids}
  end
end
