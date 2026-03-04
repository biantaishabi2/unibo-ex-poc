defmodule UniboV4.Sign do
  use Ash.Domain

  resources do
    resource UniboV4.Sign.SignTemplate
    resource UniboV4.Sign.SignItem
    resource UniboV4.Sign.SignRole
    resource UniboV4.Sign.SignRequest
    resource UniboV4.Sign.SignRequestItem
    resource UniboV4.Sign.SignLog
    resource UniboV4.Sign.User
  end
end
