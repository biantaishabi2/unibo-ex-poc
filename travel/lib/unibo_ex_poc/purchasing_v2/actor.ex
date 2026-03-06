defmodule UniboExPoc.PurchasingV2.Actor do
  @moduledoc """
  V2 Actor：用于在 GraphQL -> Ash 链路中传递当前操作者。
  """

  @enforce_keys [:id, :role]
  defstruct [:id, :role]
end
