defmodule UniboExPoc.Quality do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Quality.QualityPoint
    resource UniboExPoc.Quality.QualityPoint.Version
    resource UniboExPoc.Quality.QualityCheck
    resource UniboExPoc.Quality.QualityCheck.Version
    resource UniboExPoc.Quality.QualityAlert
    resource UniboExPoc.Quality.QualityAlert.Version
    resource UniboExPoc.Quality.QualityTeam
    resource UniboExPoc.Quality.QualityTeam.Version
    resource UniboExPoc.Quality.QualityReason
    resource UniboExPoc.Quality.QualityReason.Version
    resource UniboExPoc.Quality.QualityTag
    resource UniboExPoc.Quality.QualityTag.Version
    resource UniboExPoc.Quality.QualityProfile
    resource UniboExPoc.Quality.QualityProfile.Version
    resource UniboExPoc.Quality.QualityPointOrgView
    resource UniboExPoc.Quality.QualityPointOrgView.Version
    resource UniboExPoc.Quality.Product
    resource UniboExPoc.Quality.Lot
    resource UniboExPoc.Quality.Party
    resource UniboExPoc.Quality.Workcenter
    resource UniboExPoc.Quality.WorkOrderOperation
    resource UniboExPoc.Quality.WorksheetTemplate
    resource UniboExPoc.Quality.MaintenanceRequest
    resource UniboExPoc.Quality.QualityPointProductLink
    resource UniboExPoc.Quality.QualityTeamMemberLink
  end
end
