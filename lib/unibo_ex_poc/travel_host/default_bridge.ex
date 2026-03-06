defmodule UniboExPoc.TravelHost.DefaultBridge do
  @moduledoc """
  POC 本地 fallback bridge。
  当真实宿主 transport 尚未接入时，继续复用本地规则作为默认实现或测试替身。
  """

  @behaviour UniboExPoc.TravelHost.Bridge

  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.EligibilityOrQuote
  alias UniboExPoc.TravelHost.HostConfig
  alias UniboExPoc.TravelHost.PaymentExecution

  @impl true
  def resolve_context(raw_context, _opts), do: CallerContext.normalize(raw_context)

  @impl true
  def quote(order_attrs, %CallerContext{} = context, opts) do
    case Keyword.fetch(opts, :host_config) do
      {:ok, host_config} ->
        config = HostConfig.new(host_config || %{})
        available_points = Keyword.get(opts, :available_points, 0)

        {:ok,
         EligibilityOrQuote.build(order_attrs, context, config,
           available_points: available_points
         )}

      :error ->
        {:error, :missing_host_config}
    end
  end

  @impl true
  def execute_payment(method, %EligibilityOrQuote{} = quote, opts) do
    PaymentExecution.execute(method, quote, opts)
  end
end
