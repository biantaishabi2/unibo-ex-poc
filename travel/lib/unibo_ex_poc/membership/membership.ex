defmodule UniboExPoc.Membership do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Membership.MembershipLine
    resource UniboExPoc.Membership.MembershipLine.Version
    resource UniboExPoc.Membership.MembershipProduct
    resource UniboExPoc.Membership.MembershipProduct.Version
    resource UniboExPoc.Membership.Party
  end
end
