defmodule UniboExPoc.TravelHost.Transport do
  @moduledoc """
  宿主 bridge client 的最小传输抽象。
  现在只定义三类操作，后续可以替换成真实 HTTP/RPC transport。
  """

  @callback request(atom(), map(), keyword()) :: {:ok, map()} | {:error, term()}
end
