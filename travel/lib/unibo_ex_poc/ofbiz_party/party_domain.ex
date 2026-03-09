defmodule UniboExPoc.Ofbiz.Party do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Party.Party
    resource UniboExPoc.Ofbiz.Party.Party.Version
    resource UniboExPoc.Ofbiz.Party.PartyGroup
    resource UniboExPoc.Ofbiz.Party.PartyGroup.Version
    resource UniboExPoc.Ofbiz.Party.PartyRole
    resource UniboExPoc.Ofbiz.Party.PartyRole.Version
    resource UniboExPoc.Ofbiz.Party.PartyType
    resource UniboExPoc.Ofbiz.Party.PartyType.Version
    resource UniboExPoc.Ofbiz.Party.RoleType
    resource UniboExPoc.Ofbiz.Party.RoleType.Version
    resource UniboExPoc.Ofbiz.Party.DataSource
    resource UniboExPoc.Ofbiz.Party.StatusItem
    resource UniboExPoc.Ofbiz.Party.Uom
    resource UniboExPoc.Ofbiz.Party.UserLogin
  end
end
