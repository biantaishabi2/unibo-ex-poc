defmodule UniboExPoc.Ofbiz.Common do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Common.DataSource
    resource UniboExPoc.Ofbiz.Common.DataSourceType
    resource UniboExPoc.Ofbiz.Common.Enumeration
    resource UniboExPoc.Ofbiz.Common.EnumerationType
    resource UniboExPoc.Ofbiz.Common.Geo
    resource UniboExPoc.Ofbiz.Common.GeoType
  end
end
