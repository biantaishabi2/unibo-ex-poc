defmodule UniboV4.Ofbiz.Marketing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Ofbiz.Marketing.MarketingCampaign
    resource UniboV4.Ofbiz.Marketing.MarketingCampaign.Version
    resource UniboV4.Ofbiz.Marketing.MarketingCampaignNote
    resource UniboV4.Ofbiz.Marketing.MarketingCampaignNote.Version
    resource UniboV4.Ofbiz.Marketing.MarketingCampaignPrice
    resource UniboV4.Ofbiz.Marketing.MarketingCampaignPromo
    resource UniboV4.Ofbiz.Marketing.MarketingCampaignRole
    resource UniboV4.Ofbiz.Marketing.ContactList
    resource UniboV4.Ofbiz.Marketing.ContactList.Version
    resource UniboV4.Ofbiz.Marketing.WebSiteContactList
    resource UniboV4.Ofbiz.Marketing.ContactListCommStatus
    resource UniboV4.Ofbiz.Marketing.ContactListParty
    resource UniboV4.Ofbiz.Marketing.ContactListPartyStatus
    resource UniboV4.Ofbiz.Marketing.ContactListType
    resource UniboV4.Ofbiz.Marketing.ContactListType.Version
    resource UniboV4.Ofbiz.Marketing.SegmentGroup
    resource UniboV4.Ofbiz.Marketing.SegmentGroup.Version
    resource UniboV4.Ofbiz.Marketing.SegmentGroupClassification
    resource UniboV4.Ofbiz.Marketing.SegmentGroupClassification.Version
    resource UniboV4.Ofbiz.Marketing.SegmentGroupGeo
    resource UniboV4.Ofbiz.Marketing.SegmentGroupGeo.Version
    resource UniboV4.Ofbiz.Marketing.SegmentGroupRole
    resource UniboV4.Ofbiz.Marketing.SegmentGroupType
    resource UniboV4.Ofbiz.Marketing.SegmentGroupType.Version
    resource UniboV4.Ofbiz.Marketing.TrackingCode
    resource UniboV4.Ofbiz.Marketing.TrackingCode.Version
    resource UniboV4.Ofbiz.Marketing.TrackingCodeOrder
    resource UniboV4.Ofbiz.Marketing.TrackingCodeOrder.Version
    resource UniboV4.Ofbiz.Marketing.TrackingCodeOrderReturn
    resource UniboV4.Ofbiz.Marketing.TrackingCodeType
    resource UniboV4.Ofbiz.Marketing.TrackingCodeType.Version
    resource UniboV4.Ofbiz.Marketing.TrackingCodeVisit
    resource UniboV4.Ofbiz.Marketing.SalesOpportunity
    resource UniboV4.Ofbiz.Marketing.SalesOpportunity.Version
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityHistory
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityHistory.Version
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityRole
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityStage
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityStage.Version
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityWorkEffort
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityWorkEffort.Version
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityQuote
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityQuote.Version
    resource UniboV4.Ofbiz.Marketing.SalesForecast
    resource UniboV4.Ofbiz.Marketing.SalesForecast.Version
    resource UniboV4.Ofbiz.Marketing.SalesForecastDetail
    resource UniboV4.Ofbiz.Marketing.SalesForecastDetail.Version
    resource UniboV4.Ofbiz.Marketing.SalesForecastHistory
    resource UniboV4.Ofbiz.Marketing.SalesForecastHistory.Version
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityCompetitor
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityCompetitor.Version
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityTrckCode
    resource UniboV4.Ofbiz.Marketing.SalesOpportunityTrckCode.Version
  end
end
