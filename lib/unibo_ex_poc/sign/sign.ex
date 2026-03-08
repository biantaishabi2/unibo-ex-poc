defmodule UniboV4.Sign do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Sign.SignTemplate
    resource UniboV4.Sign.SignTemplate.Version
    resource UniboV4.Sign.SignItem
    resource UniboV4.Sign.SignItem.Version
    resource UniboV4.Sign.SignRole
    resource UniboV4.Sign.SignRole.Version
    resource UniboV4.Sign.SignRequest
    resource UniboV4.Sign.SignRequest.Version
    resource UniboV4.Sign.SignRequestItem
    resource UniboV4.Sign.SignRequestItem.Version
    resource UniboV4.Sign.SignLog
    resource UniboV4.Sign.Party
  end
end
