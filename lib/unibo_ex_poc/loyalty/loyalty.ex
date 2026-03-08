defmodule UniboV4.Loyalty do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Loyalty.LoyaltyProgram
    resource UniboV4.Loyalty.LoyaltyProgramTranslation
    resource UniboV4.Loyalty.LoyaltyProgram.Version
    resource UniboV4.Loyalty.LoyaltyCard
    resource UniboV4.Loyalty.LoyaltyCard.Version
    resource UniboV4.Loyalty.LoyaltyRule
    resource UniboV4.Loyalty.LoyaltyRuleTranslation
    resource UniboV4.Loyalty.LoyaltyRule.Version
    resource UniboV4.Loyalty.LoyaltyReward
    resource UniboV4.Loyalty.LoyaltyRewardTranslation
    resource UniboV4.Loyalty.LoyaltyReward.Version
    resource UniboV4.Loyalty.LoyaltyTransaction
    resource UniboV4.Loyalty.LoyaltyTransaction.Version
    resource UniboV4.Loyalty.Coupon
    resource UniboV4.Loyalty.Coupon.Version
    resource UniboV4.Loyalty.CouponUsage
    resource UniboV4.Loyalty.CouponBoundParty
    resource UniboV4.Loyalty.CouponBoundParty.Version
    resource UniboV4.Loyalty.GiftCard
    resource UniboV4.Loyalty.GiftCard.Version
    resource UniboV4.Loyalty.GiftCardTransaction
    resource UniboV4.Loyalty.Party
  end
end
