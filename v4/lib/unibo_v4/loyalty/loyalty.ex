defmodule UniboV4.Loyalty.Loyalty do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Loyalty.Loyalty.LoyaltyProgram
    resource UniboV4.Loyalty.Loyalty.LoyaltyProgramTranslation
    resource UniboV4.Loyalty.Loyalty.LoyaltyCard
    resource UniboV4.Loyalty.Loyalty.LoyaltyRule
    resource UniboV4.Loyalty.Loyalty.LoyaltyRuleTranslation
    resource UniboV4.Loyalty.Loyalty.LoyaltyReward
    resource UniboV4.Loyalty.Loyalty.LoyaltyRewardTranslation
    resource UniboV4.Loyalty.Loyalty.LoyaltyTransaction
    resource UniboV4.Loyalty.Loyalty.Coupon
    resource UniboV4.Loyalty.Loyalty.CouponUsage
    resource UniboV4.Loyalty.Loyalty.CouponBoundParty
    resource UniboV4.Loyalty.Loyalty.GiftCard
    resource UniboV4.Loyalty.Loyalty.GiftCardTransaction
  end
end
