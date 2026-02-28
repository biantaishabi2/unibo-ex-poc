defmodule UniboV4.Accounts do
  use Ash.Domain

  resources do
    resource UniboV4.Accounts.User
  end
end
