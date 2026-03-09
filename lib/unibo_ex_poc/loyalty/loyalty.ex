defmodule UniboExPoc.Loyalty do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Loyalty.LoyaltyProgram
    resource UniboExPoc.Loyalty.LoyaltyProgramTranslation
    resource UniboExPoc.Loyalty.LoyaltyProgram.Version
    resource UniboExPoc.Loyalty.LoyaltyCard
    resource UniboExPoc.Loyalty.LoyaltyCard.Version
    resource UniboExPoc.Loyalty.LoyaltyRule
    resource UniboExPoc.Loyalty.LoyaltyRuleTranslation
    resource UniboExPoc.Loyalty.LoyaltyRule.Version
    resource UniboExPoc.Loyalty.LoyaltyReward
    resource UniboExPoc.Loyalty.LoyaltyRewardTranslation
    resource UniboExPoc.Loyalty.LoyaltyReward.Version
    resource UniboExPoc.Loyalty.LoyaltyTransaction
    resource UniboExPoc.Loyalty.LoyaltyTransaction.Version
    resource UniboExPoc.Loyalty.Coupon
    resource UniboExPoc.Loyalty.Coupon.Version
    resource UniboExPoc.Loyalty.CouponUsage
    resource UniboExPoc.Loyalty.CouponBoundParty
    resource UniboExPoc.Loyalty.CouponBoundParty.Version
    resource UniboExPoc.Loyalty.GiftCard
    resource UniboExPoc.Loyalty.GiftCard.Version
    resource UniboExPoc.Loyalty.GiftCardTransaction
    resource UniboExPoc.Loyalty.Party
  end
end
