defmodule UniboV4.Rating.Rating do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Rating.Rating.RatingType
    resource UniboV4.Rating.Rating.RatingTypeTranslation
    resource UniboV4.Rating.Rating.RatingCriteria
    resource UniboV4.Rating.Rating.RatingCriteriaTranslation
    resource UniboV4.Rating.Rating.Rating
    resource UniboV4.Rating.Rating.RatingScore
    resource UniboV4.Rating.Rating.RatingSummary
  end
end
