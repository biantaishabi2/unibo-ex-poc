defmodule UniboExPoc.Ofbiz.Common do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Common.DataSource
    resource UniboExPoc.Ofbiz.Common.DataSource.Version
    resource UniboExPoc.Ofbiz.Common.DataSourceType
    resource UniboExPoc.Ofbiz.Common.DataSourceType.Version
    resource UniboExPoc.Ofbiz.Common.Enumeration
    resource UniboExPoc.Ofbiz.Common.Enumeration.Version
    resource UniboExPoc.Ofbiz.Common.EnumerationType
    resource UniboExPoc.Ofbiz.Common.EnumerationType.Version
    resource UniboExPoc.Ofbiz.Common.Geo
    resource UniboExPoc.Ofbiz.Common.Geo.Version
    resource UniboExPoc.Ofbiz.Common.GeoType
    resource UniboExPoc.Ofbiz.Common.GeoType.Version
  end
end
