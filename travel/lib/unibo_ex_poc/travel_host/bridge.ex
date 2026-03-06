defmodule UniboExPoc.TravelHost.Bridge do
  @moduledoc """
  `travel` 侧消费的宿主 bridge 行为。
  `HotelFlow` 只依赖这层契约，不感知宿主本地实现或传输细节。
  """

  alias UniboExPoc.TravelHost.CallerContext
  alias UniboExPoc.TravelHost.EligibilityOrQuote
  alias UniboExPoc.TravelHost.PaymentExecution

  @callback resolve_context(map(), keyword()) :: {:ok, CallerContext.t()} | {:error, term()}
  @callback quote(map(), CallerContext.t(), keyword()) ::
              {:ok, EligibilityOrQuote.t()} | {:error, term()}
  @callback execute_payment(atom(), EligibilityOrQuote.t(), keyword()) ::
              {:ok, PaymentExecution.t()} | {:error, term()}
end
