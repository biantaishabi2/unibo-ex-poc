defmodule UniboExPoc.TravelHost.CallerContext do
  @moduledoc false

  defstruct [
    :user_id,
    :member_id,
    :enterprise_id,
    :current_shop_id,
    :request_id,
    roles: []
  ]

  def normalize(attrs) when is_map(attrs) do
    {:ok,
     %__MODULE__{
       user_id: fetch(attrs, :user_id, fetch(attrs, :"x-user-id")),
       member_id: fetch(attrs, :member_id, fetch(attrs, :"x-member-id")),
       enterprise_id: fetch(attrs, :enterprise_id, fetch(attrs, :"x-enterprise-id")),
       current_shop_id: fetch(attrs, :current_shop_id, fetch(attrs, :"x-shop-id")),
       request_id: fetch(attrs, :request_id, fetch(attrs, :"x-request-id")),
       roles: normalize_roles(fetch(attrs, :roles, fetch(attrs, :"x-roles", [])))
     }}
  end

  defp normalize_roles(value) when is_list(value), do: Enum.map(value, &to_string/1)

  defp normalize_roles(value) when is_binary(value) do
    value
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end

  defp normalize_roles(_value), do: []

  defp fetch(map, key, default \\ nil) when is_map(map) do
    string_key = key |> to_string()

    cond do
      Map.has_key?(map, key) -> Map.get(map, key)
      Map.has_key?(map, string_key) -> Map.get(map, string_key)
      true -> default
    end
  end
end

defmodule UniboExPoc.TravelHost.HostConfig do
  @moduledoc false

  defstruct [
    travel_enabled: true,
    entry_visible: true,
    points_enabled: false,
    mixed_payment_enabled: false,
    cash_payment_enabled: true,
    points_exchange_rate: Decimal.new("0"),
    min_points_to_use: 0,
    max_points_deduction_amount: nil,
    visible_enterprise_ids: [],
    allowed_product_types: nil
  ]

  def new(attrs) when is_map(attrs) do
    %__MODULE__{
      travel_enabled: Map.get(attrs, :travel_enabled, Map.get(attrs, "travel_enabled", true)),
      entry_visible: Map.get(attrs, :entry_visible, Map.get(attrs, "entry_visible", true)),
      points_enabled: Map.get(attrs, :points_enabled, Map.get(attrs, "points_enabled", false)),
      mixed_payment_enabled: Map.get(attrs, :mixed_payment_enabled, Map.get(attrs, "mixed_payment_enabled", false)),
      cash_payment_enabled: Map.get(attrs, :cash_payment_enabled, Map.get(attrs, "cash_payment_enabled", true)),
      points_exchange_rate: to_decimal(Map.get(attrs, :points_exchange_rate, Map.get(attrs, "points_exchange_rate", "0"))),
      min_points_to_use: Map.get(attrs, :min_points_to_use, Map.get(attrs, "min_points_to_use", 0)),
      max_points_deduction_amount: normalize_optional_decimal(Map.get(attrs, :max_points_deduction_amount, Map.get(attrs, "max_points_deduction_amount"))),
      visible_enterprise_ids: Map.get(attrs, :visible_enterprise_ids, Map.get(attrs, "visible_enterprise_ids", [])),
      allowed_product_types: Map.get(attrs, :allowed_product_types, Map.get(attrs, "allowed_product_types"))
    }
  end

  defp normalize_optional_decimal(nil), do: nil
  defp normalize_optional_decimal(value), do: to_decimal(value)

  defp to_decimal(%Decimal{} = value), do: value
  defp to_decimal(value) when is_integer(value), do: Decimal.new(value)
  defp to_decimal(value) when is_binary(value), do: Decimal.new(value)
  defp to_decimal(value) when is_float(value), do: Decimal.from_float(value)
  defp to_decimal(_value), do: Decimal.new("0")
end

defmodule UniboExPoc.TravelHost.EligibilityOrQuote do
  @moduledoc false

  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.HostConfig

  defstruct [
    :reason,
    :product_type,
    allowed?: false,
    travel_enabled: false,
    points_enabled: false,
    mixed_payment_enabled: false,
    cash_payment_enabled: true,
    available_points: 0,
    points_requested: 0,
    points_sufficient: false,
    points_deduction_amount: Decimal.new("0"),
    payable_amount: Decimal.new("0"),
    recommended_payment_method: :cash
  ]

  def build(order_attrs, %CallerContext{} = context, %HostConfig{} = config, opts \\ []) do
    product_type = normalize_atom(Map.get(order_attrs, :product_type, :hotel))
    total_amount = to_decimal(Map.get(order_attrs, :total_amount, Decimal.new("0")))
    available_points = Keyword.get(opts, :available_points, 0)
    points_requested = Map.get(order_attrs, :points_to_use, 0)

    cond do
      not config.travel_enabled ->
        denied(product_type, total_amount, :travel_disabled, config, available_points, points_requested)

      visible_enterprise_restricted?(config, context.enterprise_id) ->
        denied(product_type, total_amount, :enterprise_not_visible, config, available_points, points_requested)

      product_disallowed?(config, product_type) ->
        denied(product_type, total_amount, :product_type_not_allowed, config, available_points, points_requested)

      true ->
        points_to_use =
          if config.points_enabled and points_requested >= config.min_points_to_use do
            min(points_requested, available_points)
          else
            0
          end

        raw_deduction = Decimal.mult(Decimal.new(points_to_use), config.points_exchange_rate)

        capped_deduction =
          raw_deduction
          |> min_decimal(total_amount)
          |> maybe_cap(config.max_points_deduction_amount)

        payable_amount = Decimal.sub(total_amount, capped_deduction)

        %__MODULE__{
          allowed?: true,
          product_type: product_type,
          travel_enabled: config.travel_enabled,
          points_enabled: config.points_enabled,
          mixed_payment_enabled: config.mixed_payment_enabled,
          cash_payment_enabled: config.cash_payment_enabled,
          available_points: available_points,
          points_requested: points_requested,
          points_sufficient: points_requested <= available_points,
          points_deduction_amount: capped_deduction,
          payable_amount: payable_amount,
          recommended_payment_method: recommended_method(config, capped_deduction, payable_amount)
        }
    end
  end

  def from_host_payload(payload) when is_map(payload) do
    %__MODULE__{
      allowed?: fetch(payload, :allowed, false),
      reason: normalize_reason(fetch(payload, :reason)),
      product_type: normalize_atom(fetch(payload, :product_type, :hotel)),
      travel_enabled: fetch(payload, :travel_enabled, false),
      points_enabled: fetch(payload, :points_enabled, false),
      mixed_payment_enabled: fetch(payload, :mixed_payment_enabled, fetch(payload, :mixed_payment_allowed, false)),
      cash_payment_enabled: fetch(payload, :cash_payment_enabled, true),
      available_points: fetch(payload, :available_points, 0),
      points_requested: fetch(payload, :points_requested, 0),
      points_sufficient: fetch(payload, :points_sufficient, false),
      points_deduction_amount: to_decimal(fetch(payload, :points_deduction_amount, "0")),
      payable_amount: to_decimal(fetch(payload, :payable_amount, "0")),
      recommended_payment_method: normalize_payment_method(fetch(payload, :recommended_payment_method, "cash"))
    }
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
      points_sufficient: points_requested <= available_points,
      points_deduction_amount: Decimal.new("0"),
      payable_amount: total_amount,
      recommended_payment_method: :cash
    }
  end

  defp recommended_method(config, deduction, payable_amount) do
    cond do
      Decimal.gt?(deduction, 0) and Decimal.equal?(payable_amount, Decimal.new("0")) ->
        :points

      Decimal.gt?(deduction, 0) and config.mixed_payment_enabled and config.cash_payment_enabled ->
        :mixed

      true ->
        :cash
    end
  end

  defp visible_enterprise_restricted?(%HostConfig{visible_enterprise_ids: []}, _enterprise_id), do: false
  defp visible_enterprise_restricted?(%HostConfig{visible_enterprise_ids: nil}, _enterprise_id), do: false
  defp visible_enterprise_restricted?(%HostConfig{visible_enterprise_ids: ids}, enterprise_id), do: enterprise_id not in ids

  defp product_disallowed?(%HostConfig{allowed_product_types: nil}, _product_type), do: false
  defp product_disallowed?(%HostConfig{allowed_product_types: allowed}, product_type), do: product_type not in allowed

  defp maybe_cap(value, nil), do: value
  defp maybe_cap(value, cap), do: min_decimal(value, cap)

  defp min_decimal(left, right) do
    case Decimal.compare(left, right) do
      :gt -> right
      _ -> left
    end
  end

  defp normalize_reason(nil), do: nil
  defp normalize_reason(value), do: normalize_atom(value)

  defp normalize_payment_method(value) do
    case normalize_atom(value) do
      :mixed -> :mixed
      :points -> :points
      :cash -> :cash
      :wechat -> :cash
      :alipay -> :cash
      other -> other
    end
  end

  defp normalize_atom(value) when is_atom(value), do: value
  defp normalize_atom(value) when is_binary(value), do: value |> String.trim() |> String.to_atom()

  defp fetch(map, key, default \\ nil) when is_map(map) do
    string_key = key |> to_string()

    cond do
      Map.has_key?(map, key) -> Map.get(map, key)
      Map.has_key?(map, string_key) -> Map.get(map, string_key)
      true -> default
    end
  end

  defp to_decimal(%Decimal{} = value), do: value
  defp to_decimal(value) when is_integer(value), do: Decimal.new(value)
  defp to_decimal(value) when is_binary(value), do: Decimal.new(value)
  defp to_decimal(value) when is_float(value), do: Decimal.from_float(value)
  defp to_decimal(_value), do: Decimal.new("0")
end

defmodule UniboExPoc.TravelHost.PaymentExecution do
  @moduledoc false

  alias UniboExPoc.TravelHost.EligibilityOrQuote

  defstruct [
    status: :approved,
    method: :cash,
    external_ref: nil,
    points_used: 0,
    points_deduction_amount: Decimal.new("0"),
    cash_amount: Decimal.new("0")
  ]

  def execute(method, %EligibilityOrQuote{} = quote, opts \\ []) do
    {:ok,
     %__MODULE__{
       status: :approved,
       method: normalize_method(method),
       external_ref: Keyword.get(opts, :external_ref),
       points_used: quote.points_requested,
       points_deduction_amount: quote.points_deduction_amount,
       cash_amount: quote.payable_amount
     }}
  end

  def from_host_payload(payload) when is_map(payload) do
    %__MODULE__{
      status: normalize_atom(fetch(payload, :status, :approved)),
      method: normalize_method(fetch(payload, :method, :cash)),
      external_ref: fetch(payload, :external_ref),
      points_used: fetch(payload, :points_used, 0),
      points_deduction_amount: to_decimal(fetch(payload, :points_deduction_amount, "0")),
      cash_amount: to_decimal(fetch(payload, :cash_amount, "0"))
    }
  end

  defp normalize_method(value) do
    case normalize_atom(value) do
      :wechat -> :cash
      other -> other
    end
  end

  defp normalize_atom(value) when is_atom(value), do: value
  defp normalize_atom(value) when is_binary(value), do: value |> String.trim() |> String.to_atom()

  defp fetch(map, key, default \\ nil) when is_map(map) do
    string_key = key |> to_string()

    cond do
      Map.has_key?(map, key) -> Map.get(map, key)
      Map.has_key?(map, string_key) -> Map.get(map, string_key)
      true -> default
    end
  end

  defp to_decimal(%Decimal{} = value), do: value
  defp to_decimal(value) when is_integer(value), do: Decimal.new(value)
  defp to_decimal(value) when is_binary(value), do: Decimal.new(value)
  defp to_decimal(value) when is_float(value), do: Decimal.from_float(value)
  defp to_decimal(_value), do: Decimal.new("0")
end

defmodule UniboExPoc.TravelHost.HTTPTransport do
  @moduledoc false

  def request(operation, payload, opts) do
    base_url = Keyword.fetch!(opts, :base_url)
    http_client = Keyword.fetch!(opts, :http_client)
    endpoint_paths = Keyword.get(opts, :endpoint_paths, %{})
    http_options = Keyword.get(opts, :http_options, [])
    path = Map.get(endpoint_paths, operation, default_path(operation))

    with {:ok, response} <- http_client.(base_url <> path, [{"content-type", "application/json"}], Jason.encode!(payload), http_options) do
      decode_response(response)
    end
  end

  defp default_path(:resolve_context), do: "/internal/api/travel_host_bridge/resolve_context"
  defp default_path(:quote), do: "/internal/api/travel_host_bridge/quote"
  defp default_path(:execute_payment), do: "/internal/api/travel_host_bridge/execute_payment"

  defp decode_response(%{status: status, body: body}) when status in 200..299 do
    {:ok, Jason.decode!(body)}
  end

  defp decode_response(%{status: status, body: body}) do
    decoded = Jason.decode!(body)
    error = decoded["error"] || %{}
    {:error, {:host_error, status, error["code"], error["message"]}}
  end
end

defmodule UniboExPoc.TravelHost.ShopBridgeClient do
  @moduledoc false

  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.EligibilityOrQuote
  alias UniboExPoc.TravelHost.HTTPTransport
  alias UniboExPoc.TravelHost.PaymentExecution

  def resolve_context(headers, opts \\ []) do
    transport = Keyword.get(opts, :transport, HTTPTransport)
    transport_opts = Keyword.get(opts, :transport_opts, [])

    with {:ok, response} <- transport.request(:resolve_context, %{caller_context: headers}, transport_opts),
         {:ok, context} <- CallerContext.normalize(response["caller_context"] || response[:caller_context] || %{}) do
      {:ok, context}
    end
  end

  def quote(order_attrs, %CallerContext{} = context, opts \\ []) do
    transport = Keyword.get(opts, :transport, HTTPTransport)
    transport_opts = Keyword.get(opts, :transport_opts, [])

    payload = %{
      caller_context: Map.from_struct(context),
      quote_request: %{
        available_points: Keyword.get(opts, :available_points, 0),
        host_config: Keyword.get(opts, :host_config, %{})
      },
      order: stringify_keys(order_attrs)
    }

    with {:ok, response} <- transport.request(:quote, payload, transport_opts) do
      quote_payload = response["eligibility_or_quote"] || response[:eligibility_or_quote] || %{}
      {:ok, EligibilityOrQuote.from_host_payload(quote_payload)}
    end
  end

  def execute_payment(method, %EligibilityOrQuote{} = quote, opts \\ []) do
    transport = Keyword.get(opts, :transport, HTTPTransport)
    transport_opts = Keyword.get(opts, :transport_opts, [])
    payment_request = Keyword.get(opts, :payment_request, %{})

    payload = %{
      payment_request: %{
        method: method |> to_string(),
        external_ref: Map.get(payment_request, :order_id),
        metadata: Map.drop(payment_request, [:order_id])
      },
      eligibility_or_quote: Map.from_struct(quote)
    }

    with {:ok, response} <- transport.request(:execute_payment, payload, transport_opts) do
      payment_payload = response["payment_execution"] || response[:payment_execution] || %{}
      {:ok, PaymentExecution.from_host_payload(payment_payload)}
    end
  end

  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {to_string(k), v} end)
  end
end

defmodule UniboExPoc.TestSupport.FakeShopTransport do
  @moduledoc false

  def request(operation, payload, opts) do
    if test_pid = Keyword.get(opts, :test_pid) do
      send(test_pid, {:fake_shop_transport, operation, payload})
    end

    case Keyword.get(opts, :responses, %{}) |> Map.get(operation) do
      fun when is_function(fun, 1) -> fun.(payload)
      {:ok, _} = ok -> ok
      {:error, _} = error -> error
      nil -> {:error, {:missing_fake_response, operation}}
    end
  end
end

defmodule UniboExPoc.TravelSupplier.HotelMockAdapter do
  @moduledoc false

  def pull_incremental_updates(cursor, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    events = [
      %{order_no: "travel-001", status: :confirmed},
      %{order_no: "travel-002", status: :issued}
    ]

    offset =
      case cursor do
        %{offset: value} when is_integer(value) -> value
        _ -> 0
      end

    page = Enum.slice(events, offset, limit)
    next_offset = offset + length(page)
    next_cursor = if next_offset < length(events), do: %{offset: next_offset}, else: nil
    {:ok, %{events: page, next_cursor: next_cursor}}
  end
end

defmodule UniboExPoc.TravelStack.HotelFlow do
  @moduledoc false

  alias UniboExPoc.Travel.TravelFulfillment
  alias UniboExPoc.Travel.TravelOrder
  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.EligibilityOrQuote
  alias UniboExPoc.TravelHost.HostConfig
  alias UniboExPoc.TravelHost.PaymentExecution

  def book(input, opts \\ []) do
    with {:ok, context} <- resolve_context(input, opts),
         {:ok, quote} <- resolve_quote(input, context, opts),
         {:ok, payment} <- resolve_payment(quote, input, opts),
         {:ok, supplier_request, fulfillment} <- submit_supplier(input, context, opts) do
      {:ok,
       %{
         context: context,
         quote: quote,
         payment: payment,
         order: %{
           resource_module: TravelOrder,
           status: :booked,
           payment_status: :paid,
           supplier_order_ref: "hotel-booking-#{input.order.order_no}"
         },
         fulfillment:
           Map.merge(fulfillment, %{
             resource_module: TravelFulfillment,
             status: :confirmed,
             supplier_booking_ref: "hotel-booking-#{input.order.order_no}",
             voucher_or_ticket_ref: "voucher-#{input.order.order_no}"
           }),
         supplier_request: supplier_request
       }}
    end
  end

  defp resolve_context(input, opts) do
    if bridge = opts[:bridge] do
      bridge.resolve_context(input.context, Keyword.get(opts, :bridge_opts, []))
    else
      CallerContext.normalize(input.context)
    end
  end

  defp resolve_quote(input, context, opts) do
    if bridge = opts[:bridge] do
      bridge.quote(
        input.order,
        context,
        Keyword.get(opts, :bridge_opts, []) ++
          [available_points: Keyword.get(opts, :available_points, 0), host_config: input.host_config]
      )
    else
      config = HostConfig.new(input.host_config || %{})
      {:ok, EligibilityOrQuote.build(input.order, context, config, available_points: Keyword.get(opts, :available_points, 0))}
    end
  end

  defp resolve_payment(quote, input, opts) do
    method = Keyword.get(opts, :payment_method, :cash)

    if bridge = opts[:bridge] do
      bridge.execute_payment(
        method,
        quote,
        Keyword.get(opts, :bridge_opts, []) ++
          [
            payment_request:
              %{
                order_id: input.order.order_no,
                payment_environment: get_in(input, [:payment, :cashier]) && "H5" || "MINIAPP",
                scene: "hotel_order",
                cashier: get_in(input, [:payment, :cashier])
              }
          ]
      )
    else
      PaymentExecution.execute(method, quote, external_ref: input.order.order_no)
    end
  end

  defp submit_supplier(input, context, opts) do
    case get_in(opts, [:supplier_adapter_opts, :simulate]) do
      :supplier_rejected ->
        {:error, %{code: :supplier_rejected, retryable?: false}}

      :timeout ->
        {:error, %{code: :timeout, retryable?: true}}

      _ ->
        {:ok,
         %{
           supplier_code: input.order.supplier_code,
           member_id: context.member_id,
           supplier_payload: %{supplier_hotel_id: input.order.hotel_code}
         }, %{}}
    end
  end
end
