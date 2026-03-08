defmodule UniboV4.Ofbiz.Security do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Ofbiz.Security.X509IssuerProvision
    resource UniboV4.Ofbiz.Security.X509IssuerProvision.Version
    resource UniboV4.Ofbiz.Security.UserLogin
    resource UniboV4.Ofbiz.Security.UserLogin.Version
    resource UniboV4.Ofbiz.Security.UserLoginPasswordHistory
    resource UniboV4.Ofbiz.Security.UserLoginPasswordHistory.Version
    resource UniboV4.Ofbiz.Security.UserLoginHistory
    resource UniboV4.Ofbiz.Security.UserLoginHistory.Version
    resource UniboV4.Ofbiz.Security.UserLoginSession
    resource UniboV4.Ofbiz.Security.UserLoginSession.Version
    resource UniboV4.Ofbiz.Security.SecurityGroup
    resource UniboV4.Ofbiz.Security.SecurityGroup.Version
    resource UniboV4.Ofbiz.Security.SecurityGroupPermission
    resource UniboV4.Ofbiz.Security.SecurityGroupPermission.Version
    resource UniboV4.Ofbiz.Security.SecurityPermission
    resource UniboV4.Ofbiz.Security.SecurityPermission.Version
    resource UniboV4.Ofbiz.Security.UserLoginSecurityGroup
    resource UniboV4.Ofbiz.Security.UserLoginSecurityGroup.Version
    resource UniboV4.Ofbiz.Security.ProtectedView
    resource UniboV4.Ofbiz.Security.ProtectedView.Version
    resource UniboV4.Ofbiz.Security.TarpittedLoginView
    resource UniboV4.Ofbiz.Security.TarpittedLoginView.Version
  end
end
