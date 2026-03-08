defmodule UniboV4.Quality do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Quality.QualityPoint
    resource UniboV4.Quality.QualityPoint.Version
    resource UniboV4.Quality.QualityCheck
    resource UniboV4.Quality.QualityCheck.Version
    resource UniboV4.Quality.QualityAlert
    resource UniboV4.Quality.QualityAlert.Version
    resource UniboV4.Quality.QualityTeam
    resource UniboV4.Quality.QualityTeam.Version
    resource UniboV4.Quality.QualityReason
    resource UniboV4.Quality.QualityReason.Version
    resource UniboV4.Quality.QualityTag
    resource UniboV4.Quality.QualityTag.Version
    resource UniboV4.Quality.QualityProfile
    resource UniboV4.Quality.QualityProfile.Version
    resource UniboV4.Quality.QualityPointOrgView
    resource UniboV4.Quality.QualityPointOrgView.Version
    resource UniboV4.Quality.Product
    resource UniboV4.Quality.Lot
    resource UniboV4.Quality.Party
    resource UniboV4.Quality.Workcenter
    resource UniboV4.Quality.WorkOrderOperation
    resource UniboV4.Quality.WorksheetTemplate
    resource UniboV4.Quality.MaintenanceRequest
    resource UniboV4.Quality.QualityPointProductLink
    resource UniboV4.Quality.QualityTeamMemberLink
  end
end
