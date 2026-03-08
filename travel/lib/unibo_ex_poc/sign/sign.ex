defmodule UniboExPoc.Sign do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Sign.SignTemplate
    resource UniboExPoc.Sign.SignTemplate.Version
    resource UniboExPoc.Sign.SignItem
    resource UniboExPoc.Sign.SignItem.Version
    resource UniboExPoc.Sign.SignRole
    resource UniboExPoc.Sign.SignRole.Version
    resource UniboExPoc.Sign.SignRequest
    resource UniboExPoc.Sign.SignRequest.Version
    resource UniboExPoc.Sign.SignRequestItem
    resource UniboExPoc.Sign.SignRequestItem.Version
    resource UniboExPoc.Sign.SignLog
    resource UniboExPoc.Sign.Party
  end
end
