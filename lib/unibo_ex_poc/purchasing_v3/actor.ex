defmodule UniboExPoc.PurchasingV3.Actor do
  @moduledoc """
  V3 Actor：用于规则验证时传递操作者身份。
  """

  @enforce_keys [:id, :role]
  defstruct [:id, :role]
end
