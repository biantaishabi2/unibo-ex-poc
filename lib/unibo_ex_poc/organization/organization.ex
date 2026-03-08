defmodule UniboV4.Organization do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Organization.Party
    resource UniboV4.Organization.Party.Version
    resource UniboV4.Organization.PartyRole
    resource UniboV4.Organization.PartyRole.Version
    resource UniboV4.Organization.PartyRelationship
    resource UniboV4.Organization.PartyRelationship.Version
  end
end
