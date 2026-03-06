defmodule UniboExPoc.TravelHost.ShopBridgeClient do
  @moduledoc """
  面向真实 `shop` 宿主 bridge 的 client 外壳。
  当前只约定操作名、请求载荷和返回映射；真实宿主 ready 后只需替换 transport。
  """

  @behaviour UniboExPoc.TravelHost.Bridge

  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.EligibilityOrQuote
  alias UniboExPoc.TravelHost.PaymentExecution

  @impl true
  def resolve_context(raw_context, opts) when is_map(raw_context) do
    with {:ok, {transport, transport_opts}} <- fetch_transport(opts),
         {:ok, response} <-
           transport.request(:resolve_context, %{context: raw_context}, transport_opts),
         context_payload <- unwrap_contract(response, :caller_context),
         {:ok, context} <- CallerContext.normalize(context_payload) do
      {:ok, context}
    end
  end

  def resolve_context(_raw_context, _opts), do: {:error, :invalid_context}

  @impl true
  def quote(order_attrs, %CallerContext{} = context, opts) do
    request = %{
      caller_context: caller_context_payload(context),
      order: normalize_order_payload(order_attrs),
      quote_request: %{
        available_points: Keyword.get(opts, :available_points, 0),
        host_config: Keyword.get(opts, :host_config)
      }
    }

    with {:ok, {transport, transport_opts}} <- fetch_transport(opts),
         {:ok, response} <- transport.request(:quote, request, transport_opts),
         quote_payload <- unwrap_contract(response, :eligibility_or_quote) do
      {:ok, build_quote(quote_payload)}
    end
  end

  @impl true
  def execute_payment(method, %EligibilityOrQuote{} = quote, opts) do
    request = %{
      payment_request: payment_request_payload(method, opts),
      eligibility_or_quote: quote_payload(quote)
    }

    with {:ok, {transport, transport_opts}} <- fetch_transport(opts),
         {:ok, response} <- transport.request(:execute_payment, request, transport_opts),
         payment_payload <- unwrap_contract(response, :payment_execution) do
      {:ok, build_payment(payment_payload, method)}
    end
  end

  defp fetch_transport(opts) do
    case Keyword.get(opts, :transport) do
      nil ->
        {:error, :missing_transport}

      {transport, inline_opts} when is_atom(transport) and is_list(inline_opts) ->
        {:ok, {transport, Keyword.merge(inline_opts, Keyword.get(opts, :transport_opts, []))}}

      transport when is_atom(transport) ->
        {:ok, {transport, Keyword.get(opts, :transport_opts, [])}}

      _other ->
        {:error, :invalid_transport}
    end
  end

  defp unwrap_contract(response, key) do
    Map.get(response, key) || Map.get(response, Atom.to_string(key)) || response
  end

  defp caller_context_payload(%CallerContext{} = context) do
    %{
      user_id: context.user_id,
      member_id: context.member_id,
      enterprise_id: context.enterprise_id,
      current_shop_id: context.current_shop_id,
      request_id: context.request_id,
      roles: context.roles
    }
  end

  defp quote_payload(%EligibilityOrQuote{} = quote) do
    %{
      allowed: quote.allowed?,
      reason: quote.reason,
      product_type: to_string(quote.product_type),
      travel_enabled: quote.travel_enabled,
      points_enabled: quote.points_enabled,
      mixed_payment_enabled: quote.mixed_payment_enabled,
      cash_payment_enabled: quote.cash_payment_enabled,
      available_points: quote.available_points,
      points_requested: quote.points_requested,
      points_sufficient: quote.points_sufficient,
      points_deduction_amount: Decimal.to_string(quote.points_deduction_amount),
      payable_amount: Decimal.to_string(quote.payable_amount),
      recommended_payment_method: to_string(quote.recommended_payment_method)
    }
  end

  defp payment_request_payload(method, opts) do
    raw_payment_request = normalize_map_like(Keyword.get(opts, :payment_request, %{}))
    nested_metadata = normalize_map_like(fetch_value(raw_payment_request, [:metadata]))

    metadata =
      raw_payment_request
      |> Map.drop([
        :metadata,
        "metadata",
        :external_ref,
        "external_ref",
        :order_id,
        "order_id",
        :method,
        "method"
      ])
      |> Map.merge(nested_metadata)

    %{
      method: to_string(method),
      external_ref:
        blank_to_nil(Keyword.get(opts, :external_ref)) ||
          blank_to_nil(fetch_value(raw_payment_request, [:external_ref, :order_id])),
      metadata: metadata
    }
  end

  defp normalize_map_like(value) when is_map(value), do: value

  defp normalize_map_like(value) when is_list(value) do
    if Keyword.keyword?(value) do
      Map.new(value)
    else
      %{}
    end
  end

  defp normalize_map_like(_value), do: %{}

  defp normalize_order_payload(order_attrs) when is_map(order_attrs) do
    order_attrs
    |> Enum.into(%{}, fn {key, value} -> {to_string(key), normalize_payload_value(value)} end)
  end

  defp normalize_payload_value(%Decimal{} = value), do: Decimal.to_string(value)
  defp normalize_payload_value(%Date{} = value), do: Date.to_iso8601(value)

  defp normalize_payload_value(value) when is_map(value) do
    Enum.into(value, %{}, fn {key, inner_value} ->
      {to_string(key), normalize_payload_value(inner_value)}
    end)
  end

  defp normalize_payload_value(value) when is_list(value),
    do: Enum.map(value, &normalize_payload_value/1)

  defp normalize_payload_value(value), do: value

  defp build_quote(payload) when is_map(payload) do
    %EligibilityOrQuote{
      allowed?: fetch_boolean(payload, [:allowed?, :allowed], false),
      reason: fetch_reason(payload, [:reason]),
      product_type: fetch_product_type(payload, [:product_type], :hotel),
      travel_enabled: fetch_boolean(payload, [:travel_enabled], false),
      points_enabled: fetch_boolean(payload, [:points_enabled], false),
      mixed_payment_enabled: fetch_boolean(payload, [:mixed_payment_enabled], false),
      cash_payment_enabled: fetch_boolean(payload, [:cash_payment_enabled], false),
      available_points: fetch_integer(payload, [:available_points], 0),
      points_requested: fetch_integer(payload, [:points_requested], 0),
      points_sufficient: fetch_boolean(payload, [:points_sufficient], false),
      points_deduction_amount: fetch_decimal(payload, [:points_deduction_amount], "0"),
      payable_amount: fetch_decimal(payload, [:payable_amount], "0"),
      recommended_payment_method: fetch_method(payload, [:recommended_payment_method], :cash)
    }
  end

  defp build_payment(payload, fallback_method) when is_map(payload) do
    %PaymentExecution{
      status: fetch_status(payload, [:status], :declined),
      method: fetch_method(payload, [:method], fallback_method),
      external_ref: fetch_value(payload, [:external_ref]),
      points_used: fetch_integer(payload, [:points_used], 0),
      points_deduction_amount: fetch_decimal(payload, [:points_deduction_amount], "0"),
      cash_amount: fetch_decimal(payload, [:cash_amount], "0"),
      reason: fetch_reason(payload, [:reason])
    }
  end

  defp fetch_boolean(payload, keys, default) do
    case fetch_value(payload, keys) do
      value when value in [true, false] -> value
      value when is_binary(value) -> value in ["true", "1"]
      _other -> default
    end
  end

  defp fetch_integer(payload, keys, default) do
    case fetch_value(payload, keys) do
      value when is_integer(value) ->
        value

      value when is_binary(value) and value != "" ->
        case Integer.parse(value) do
          {integer, ""} -> integer
          _other -> default
        end

      _other ->
        default
    end
  end

  defp fetch_decimal(payload, keys, default) do
    case fetch_value(payload, keys) do
      %Decimal{} = value -> value
      nil -> Decimal.new(default)
      value -> Decimal.new(to_string(value))
    end
  end

  defp fetch_method(payload, keys, default) do
    case fetch_value(payload, keys) do
      value when value in [:cash, :points, :mixed, :unavailable, :wechat] ->
        normalize_method(value)

      "cash" ->
        :cash

      "points" ->
        :points

      "mixed" ->
        :mixed

      "unavailable" ->
        :unavailable

      "wechat" ->
        :cash

      _other ->
        default
    end
  end

  defp normalize_method(:wechat), do: :cash
  defp normalize_method(method), do: method

  defp fetch_product_type(payload, keys, default) do
    case fetch_value(payload, keys) do
      value when value in [:hotel, :flight, :vacation] -> value
      "hotel" -> :hotel
      "flight" -> :flight
      "vacation" -> :vacation
      _other -> default
    end
  end

  defp fetch_status(payload, keys, default) do
    case fetch_value(payload, keys) do
      value when value in [:approved, :declined] -> value
      "approved" -> :approved
      "declined" -> :declined
      _other -> default
    end
  end

  defp fetch_reason(payload, keys) do
    case fetch_value(payload, keys) do
      nil -> nil
      value when is_atom(value) -> value
      "travel_disabled" -> :travel_disabled
      "enterprise_not_visible" -> :enterprise_not_visible
      "product_type_not_allowed" -> :product_type_not_allowed
      "quote_not_allowed" -> :quote_not_allowed
      "points_not_enough" -> :points_not_enough
      "payment_method_not_allowed" -> :payment_method_not_allowed
      value when is_binary(value) -> value
      value -> value
    end
  end

  defp fetch_value(payload, [key | rest]) do
    string_key = Atom.to_string(key)

    cond do
      Map.has_key?(payload, key) -> Map.get(payload, key)
      Map.has_key?(payload, string_key) -> Map.get(payload, string_key)
      true -> fetch_value(payload, rest)
    end
  end

  defp fetch_value(_payload, []), do: nil

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil

  defp blank_to_nil(value) when is_binary(value) do
    trimmed = String.trim(value)

    if trimmed == "" do
      nil
    else
      trimmed
    end
  end

  defp blank_to_nil(value), do: value
end
