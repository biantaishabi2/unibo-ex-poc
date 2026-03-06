defmodule UniboExPoc.TravelHost.EligibilityOrQuote do
  @moduledoc """
  宿主对 travel 暴露的下单前预检和报价结果。
  """

  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.HostConfig

  defstruct allowed?: false,
            reason: nil,
            product_type: :hotel,
            travel_enabled: false,
            points_enabled: false,
            mixed_payment_enabled: false,
            cash_payment_enabled: false,
            available_points: 0,
            points_requested: 0,
            points_sufficient: false,
            points_deduction_amount: Decimal.new("0"),
            payable_amount: Decimal.new("0"),
            recommended_payment_method: :cash

  @type t :: %__MODULE__{}

  @spec build(map(), CallerContext.t(), HostConfig.t(), keyword()) :: t()
  def build(order_attrs, %CallerContext{} = context, %HostConfig{} = config, opts \\ []) do
    product_type = normalize_product_type(Map.get(order_attrs, :product_type, :hotel))
    total_amount = decimal(Map.get(order_attrs, :total_amount, 0))
    points_requested = integer(Map.get(order_attrs, :points_to_use, 0))
    available_points = Keyword.get(opts, :available_points, 0)

    cond do
      not config.travel_enabled ->
        denied(product_type, total_amount, :travel_disabled, config, available_points, points_requested)

      not HostConfig.allowed_enterprise?(config, context.enterprise_id) ->
        denied(product_type, total_amount, :enterprise_not_visible, config, available_points, points_requested)

      not HostConfig.supports_product?(config, product_type) ->
        denied(product_type, total_amount, :product_type_not_allowed, config, available_points, points_requested)

      true ->
        points_enabled? = config.points_enabled and available_points >= config.min_points_to_use
        points_sufficient? = points_requested <= available_points

        points_deduction_amount =
          calculate_points_deduction(points_requested, available_points, total_amount, config)

        payable_amount = Decimal.max(Decimal.sub(total_amount, points_deduction_amount), Decimal.new("0"))

        %__MODULE__{
          allowed?: true,
          product_type: product_type,
          travel_enabled: config.travel_enabled,
          points_enabled: points_enabled?,
          mixed_payment_enabled: config.mixed_payment_enabled,
          cash_payment_enabled: config.cash_payment_enabled,
          available_points: available_points,
          points_requested: points_requested,
          points_sufficient: points_sufficient?,
          points_deduction_amount: points_deduction_amount,
          payable_amount: payable_amount,
          recommended_payment_method:
            recommend_payment_method(points_enabled?, config, payable_amount, points_deduction_amount)
        }
    end
  end

  defp denied(product_type, total_amount, reason, config, available_points, points_requested) do
    %__MODULE__{
      allowed?: false,
      reason: reason,
      product_type: product_type,
      travel_enabled: config.travel_enabled,
      points_enabled: config.points_enabled,
      mixed_payment_enabled: config.mixed_payment_enabled,
      cash_payment_enabled: config.cash_payment_enabled,
      available_points: available_points,
      points_requested: points_requested,
      points_sufficient: false,
      points_deduction_amount: Decimal.new("0"),
      payable_amount: total_amount,
      recommended_payment_method: :cash
    }
  end

  defp calculate_points_deduction(points_requested, available_points, total_amount, config) do
    points_to_apply = min(points_requested, available_points)
    requested_deduction = Decimal.mult(Decimal.new(points_to_apply), config.points_exchange_rate)

    requested_deduction
    |> Decimal.min(config.max_points_deduction_amount)
    |> Decimal.min(total_amount)
  end

  defp recommend_payment_method(true, config, payable_amount, points_deduction_amount) do
    cond do
      Decimal.gt?(points_deduction_amount, 0) and Decimal.equal?(payable_amount, 0) -> :points
      Decimal.gt?(points_deduction_amount, 0) and config.mixed_payment_enabled -> :mixed
      config.cash_payment_enabled -> :cash
      true -> :points
    end
  end

  defp recommend_payment_method(false, config, _payable_amount, _points_deduction_amount) do
    if config.cash_payment_enabled, do: :cash, else: :unavailable
  end

  defp decimal(%Decimal{} = value), do: value
  defp decimal(value), do: Decimal.new(to_string(value || 0))

  defp integer(value) when is_integer(value), do: value
  defp integer(value) when is_binary(value), do: String.to_integer(value)
  defp integer(nil), do: 0

  defp normalize_product_type(value) when is_atom(value), do: value
  defp normalize_product_type(value) when is_binary(value), do: String.to_existing_atom(value)
end
