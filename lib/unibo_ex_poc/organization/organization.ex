defmodule UniboExPoc.Organization do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Organization.Party
    resource UniboExPoc.Organization.Party.Version
    resource UniboExPoc.Organization.PartyRole
    resource UniboExPoc.Organization.PartyRole.Version
    resource UniboExPoc.Organization.PartyRelationship
    resource UniboExPoc.Organization.PartyRelationship.Version
  end
end
