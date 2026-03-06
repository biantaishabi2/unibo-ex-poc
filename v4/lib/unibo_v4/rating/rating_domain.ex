defmodule UniboV4.Rating do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Rating.RatingType
    resource UniboV4.Rating.RatingTypeTranslation
    resource UniboV4.Rating.RatingCriteria
    resource UniboV4.Rating.RatingCriteriaTranslation
    resource UniboV4.Rating.Rating
    resource UniboV4.Rating.RatingScore
    resource UniboV4.Rating.RatingSummary
  end
end
