defmodule UniboExPoc.Ofbiz.Marketing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Marketing.MarketingCampaign
    resource UniboExPoc.Ofbiz.Marketing.MarketingCampaign.Version
    resource UniboExPoc.Ofbiz.Marketing.MarketingCampaignNote
    resource UniboExPoc.Ofbiz.Marketing.MarketingCampaignNote.Version
    resource UniboExPoc.Ofbiz.Marketing.MarketingCampaignPrice
    resource UniboExPoc.Ofbiz.Marketing.MarketingCampaignPromo
    resource UniboExPoc.Ofbiz.Marketing.MarketingCampaignRole
    resource UniboExPoc.Ofbiz.Marketing.ContactList
    resource UniboExPoc.Ofbiz.Marketing.ContactList.Version
    resource UniboExPoc.Ofbiz.Marketing.WebSiteContactList
    resource UniboExPoc.Ofbiz.Marketing.ContactListCommStatus
    resource UniboExPoc.Ofbiz.Marketing.ContactListParty
    resource UniboExPoc.Ofbiz.Marketing.ContactListPartyStatus
    resource UniboExPoc.Ofbiz.Marketing.ContactListType
    resource UniboExPoc.Ofbiz.Marketing.ContactListType.Version
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroup
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroup.Version
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroupClassification
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroupClassification.Version
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroupGeo
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroupGeo.Version
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroupRole
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroupType
    resource UniboExPoc.Ofbiz.Marketing.SegmentGroupType.Version
    resource UniboExPoc.Ofbiz.Marketing.TrackingCode
    resource UniboExPoc.Ofbiz.Marketing.TrackingCode.Version
    resource UniboExPoc.Ofbiz.Marketing.TrackingCodeOrder
    resource UniboExPoc.Ofbiz.Marketing.TrackingCodeOrder.Version
    resource UniboExPoc.Ofbiz.Marketing.TrackingCodeOrderReturn
    resource UniboExPoc.Ofbiz.Marketing.TrackingCodeType
    resource UniboExPoc.Ofbiz.Marketing.TrackingCodeType.Version
    resource UniboExPoc.Ofbiz.Marketing.TrackingCodeVisit
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunity
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunity.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityHistory
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityHistory.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityRole
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityStage
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityStage.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityWorkEffort
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityWorkEffort.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityQuote
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityQuote.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesForecast
    resource UniboExPoc.Ofbiz.Marketing.SalesForecast.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesForecastDetail
    resource UniboExPoc.Ofbiz.Marketing.SalesForecastDetail.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesForecastHistory
    resource UniboExPoc.Ofbiz.Marketing.SalesForecastHistory.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityCompetitor
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityCompetitor.Version
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityTrckCode
    resource UniboExPoc.Ofbiz.Marketing.SalesOpportunityTrckCode.Version
  end
end
