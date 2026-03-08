defmodule UniboV4.Membership do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Membership.MembershipLine
    resource UniboV4.Membership.MembershipLine.Version
    resource UniboV4.Membership.MembershipProduct
    resource UniboV4.Membership.MembershipProduct.Version
    resource UniboV4.Membership.Party
  end
end
