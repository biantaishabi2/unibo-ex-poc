defmodule UniboExPoc.TravelHost.PaymentExecution do
  @moduledoc """
  宿主支付执行结果。
  这里只表达 sidecar 需要消费的最小事实。
  """

  alias UniboExPoc.TravelHost.EligibilityOrQuote

  defstruct status: :declined,
            method: :cash,
            external_ref: nil,
            points_used: 0,
            points_deduction_amount: Decimal.new("0"),
            cash_amount: Decimal.new("0"),
            reason: nil

  @type t :: %__MODULE__{}

  @spec execute(atom(), EligibilityOrQuote.t(), keyword()) :: {:ok, t()} | {:error, atom()}
  def execute(_method, %EligibilityOrQuote{allowed?: false}, _opts), do: {:error, :quote_not_allowed}

  def execute(method, %EligibilityOrQuote{} = quote, opts) do
    external_ref = Keyword.get(opts, :external_ref, "pay-" <> Ecto.UUID.generate())

    case validate_method(method, quote) do
      :ok ->
        {:ok,
         %__MODULE__{
           status: :approved,
           method: method,
           external_ref: external_ref,
           points_used: points_used_for(method, quote),
           points_deduction_amount: points_amount_for(method, quote),
           cash_amount: cash_amount_for(method, quote)
         }}

      {:error, reason} ->
        {:ok,
         %__MODULE__{
           status: :declined,
           method: method,
           external_ref: external_ref,
           reason: reason,
           points_used: 0,
           points_deduction_amount: Decimal.new("0"),
           cash_amount: quote.payable_amount
         }}
    end
  end

  defp validate_method(:points, %EligibilityOrQuote{points_enabled: true, payable_amount: payable}) do
    if Decimal.equal?(payable, 0), do: :ok, else: {:error, :points_not_enough}
  end

  defp validate_method(:mixed, %EligibilityOrQuote{mixed_payment_enabled: true, points_enabled: true}), do: :ok
  defp validate_method(:cash, %EligibilityOrQuote{cash_payment_enabled: true}), do: :ok
  defp validate_method(_, _quote), do: {:error, :payment_method_not_allowed}

  defp points_used_for(:points, quote), do: quote.points_requested
  defp points_used_for(:mixed, quote), do: quote.points_requested
  defp points_used_for(_method, _quote), do: 0

  defp points_amount_for(:points, quote), do: quote.points_deduction_amount
  defp points_amount_for(:mixed, quote), do: quote.points_deduction_amount
  defp points_amount_for(_method, _quote), do: Decimal.new("0")

  defp cash_amount_for(:cash, quote), do: quote.payable_amount
  defp cash_amount_for(:mixed, quote), do: quote.payable_amount
  defp cash_amount_for(:points, _quote), do: Decimal.new("0")
end
