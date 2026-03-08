defmodule UniboExPoc.Ofbiz.Security do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Security.X509IssuerProvision
    resource UniboExPoc.Ofbiz.Security.X509IssuerProvision.Version
    resource UniboExPoc.Ofbiz.Security.UserLogin
    resource UniboExPoc.Ofbiz.Security.UserLogin.Version
    resource UniboExPoc.Ofbiz.Security.UserLoginPasswordHistory
    resource UniboExPoc.Ofbiz.Security.UserLoginPasswordHistory.Version
    resource UniboExPoc.Ofbiz.Security.UserLoginHistory
    resource UniboExPoc.Ofbiz.Security.UserLoginHistory.Version
    resource UniboExPoc.Ofbiz.Security.UserLoginSession
    resource UniboExPoc.Ofbiz.Security.UserLoginSession.Version
    resource UniboExPoc.Ofbiz.Security.SecurityGroup
    resource UniboExPoc.Ofbiz.Security.SecurityGroup.Version
    resource UniboExPoc.Ofbiz.Security.SecurityGroupPermission
    resource UniboExPoc.Ofbiz.Security.SecurityGroupPermission.Version
    resource UniboExPoc.Ofbiz.Security.SecurityPermission
    resource UniboExPoc.Ofbiz.Security.SecurityPermission.Version
    resource UniboExPoc.Ofbiz.Security.UserLoginSecurityGroup
    resource UniboExPoc.Ofbiz.Security.UserLoginSecurityGroup.Version
    resource UniboExPoc.Ofbiz.Security.ProtectedView
    resource UniboExPoc.Ofbiz.Security.ProtectedView.Version
    resource UniboExPoc.Ofbiz.Security.TarpittedLoginView
    resource UniboExPoc.Ofbiz.Security.TarpittedLoginView.Version
  end
end
