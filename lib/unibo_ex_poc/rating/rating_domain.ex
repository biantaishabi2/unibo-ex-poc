defmodule UniboExPoc.Rating do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Rating.RatingType
    resource UniboExPoc.Rating.RatingTypeTranslation
    resource UniboExPoc.Rating.RatingType.Version
    resource UniboExPoc.Rating.RatingCriteria
    resource UniboExPoc.Rating.RatingCriteriaTranslation
    resource UniboExPoc.Rating.RatingCriteria.Version
    resource UniboExPoc.Rating.Rating
    resource UniboExPoc.Rating.Rating.Version
    resource UniboExPoc.Rating.RatingScore
    resource UniboExPoc.Rating.RatingSummary
    resource UniboExPoc.Rating.RatingSummary.Version
  end
end
