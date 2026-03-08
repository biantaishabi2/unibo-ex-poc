defmodule UniboExPoc.Gamification do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Gamification.GoalDefinition
    resource UniboExPoc.Gamification.GoalDefinitionTranslation
    resource UniboExPoc.Gamification.GoalDefinition.Version
    resource UniboExPoc.Gamification.Goal
    resource UniboExPoc.Gamification.Goal.Version
    resource UniboExPoc.Gamification.Challenge
    resource UniboExPoc.Gamification.ChallengeTranslation
    resource UniboExPoc.Gamification.Challenge.Version
    resource UniboExPoc.Gamification.ChallengeLine
    resource UniboExPoc.Gamification.ChallengeLine.Version
    resource UniboExPoc.Gamification.Badge
    resource UniboExPoc.Gamification.BadgeTranslation
    resource UniboExPoc.Gamification.Badge.Version
    resource UniboExPoc.Gamification.BadgeUser
    resource UniboExPoc.Gamification.BadgeUser.Version
    resource UniboExPoc.Gamification.KarmaRank
    resource UniboExPoc.Gamification.KarmaRankTranslation
    resource UniboExPoc.Gamification.KarmaRank.Version
    resource UniboExPoc.Gamification.KarmaTracking
    resource UniboExPoc.Gamification.ChallengeUserLink
    resource UniboExPoc.Gamification.ChallengeInvitedUserLink
    resource UniboExPoc.Gamification.BadgeAuthUserLink
    resource UniboExPoc.Gamification.BadgeAuthBadgeLink
    resource UniboExPoc.Gamification.Party
  end
end
