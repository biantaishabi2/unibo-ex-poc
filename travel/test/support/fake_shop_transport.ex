defmodule UniboExPoc.TestSupport.FakeShopTransport do
  @moduledoc false

  @behaviour UniboExPoc.TravelHost.Transport

  @impl true
  def request(operation, payload, opts) do
    if pid = Keyword.get(opts, :test_pid) do
      send(pid, {:fake_shop_transport, operation, payload})
    end

    response =
      opts
      |> Keyword.get(:responses, %{})
      |> Map.get(operation)

    case response do
      nil -> {:error, {:missing_response, operation}}
      fun when is_function(fun, 1) -> fun.(payload)
      fun when is_function(fun, 2) -> fun.(payload, opts)
      value -> value
    end
  end
end
