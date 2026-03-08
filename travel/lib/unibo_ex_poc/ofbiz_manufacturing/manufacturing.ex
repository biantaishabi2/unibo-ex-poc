defmodule UniboExPoc.Ofbiz.Manufacturing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Manufacturing.ProductManufacturingRule
    resource UniboExPoc.Ofbiz.Manufacturing.ProductManufacturingRule.Version
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendar
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendar.Version
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendarExcDay
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendarExcDay.Version
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendarExcWeek
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendarExcWeek.Version
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendarWeek
    resource UniboExPoc.Ofbiz.Manufacturing.TechDataCalendarWeek.Version
    resource UniboExPoc.Ofbiz.Manufacturing.MrpEventType
    resource UniboExPoc.Ofbiz.Manufacturing.MrpEventType.Version
    resource UniboExPoc.Ofbiz.Manufacturing.MrpEvent
  end
end
