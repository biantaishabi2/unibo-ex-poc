defmodule HospitalScheduling.Accounts do
  @moduledoc """
  最小 Accounts 域，仅包含 User 资源供 PaperTrail actor 引用。
  """
  use Ash.Domain

  resources do
    resource HospitalScheduling.Accounts.User
  end
end
