defmodule UniboV4.Gamification do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Gamification.GoalDefinition
    resource UniboV4.Gamification.GoalDefinitionTranslation
    resource UniboV4.Gamification.Goal
    resource UniboV4.Gamification.Challenge
    resource UniboV4.Gamification.ChallengeTranslation
    resource UniboV4.Gamification.ChallengeLine
    resource UniboV4.Gamification.Badge
    resource UniboV4.Gamification.BadgeTranslation
    resource UniboV4.Gamification.BadgeUser
    resource UniboV4.Gamification.KarmaRank
    resource UniboV4.Gamification.KarmaRankTranslation
    resource UniboV4.Gamification.KarmaTracking
    resource UniboV4.Gamification.ChallengeUserLink
    resource UniboV4.Gamification.ChallengeInvitedUserLink
    resource UniboV4.Gamification.BadgeAuthUserLink
    resource UniboV4.Gamification.BadgeAuthBadgeLink
    resource UniboV4.Gamification.ResUser
  end
end
