defmodule UniboV4.Membership do
  use Ash.Domain

  resources do
    resource UniboV4.Membership.MembershipLine
    resource UniboV4.Membership.MembershipProduct
    resource UniboV4.Membership.ResPartner
    resource UniboV4.Membership.ResUser
  end
end
