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
    resource UniboExPoc.Organization.AuthRole
    resource UniboExPoc.Organization.AuthRole.Version
    resource UniboExPoc.Organization.AuthFeatureGrant
    resource UniboExPoc.Organization.AuthFeatureGrant.Version
    resource UniboExPoc.Organization.AuthDataScopeGrant
    resource UniboExPoc.Organization.AuthDataScopeGrant.Version
    resource UniboExPoc.Organization.AuthRoleBinding
    resource UniboExPoc.Organization.AuthRoleBinding.Version
    resource UniboExPoc.Organization.PersonProfile
    resource UniboExPoc.Organization.PersonProfile.Version
    resource UniboExPoc.Organization.Tenant
    resource UniboExPoc.Organization.Tenant.Version
    resource UniboExPoc.Organization.TenantModuleGrant
    resource UniboExPoc.Organization.TenantModuleGrant.Version
  end
end
