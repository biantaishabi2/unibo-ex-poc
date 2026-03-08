defmodule UniboV4.Ofbiz.Manufacturing do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Ofbiz.Manufacturing.ProductManufacturingRule
    resource UniboV4.Ofbiz.Manufacturing.ProductManufacturingRule.Version
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendar
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendar.Version
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendarExcDay
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendarExcDay.Version
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendarExcWeek
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendarExcWeek.Version
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendarWeek
    resource UniboV4.Ofbiz.Manufacturing.TechDataCalendarWeek.Version
    resource UniboV4.Ofbiz.Manufacturing.MrpEventType
    resource UniboV4.Ofbiz.Manufacturing.MrpEventType.Version
    resource UniboV4.Ofbiz.Manufacturing.MrpEvent
  end
end
