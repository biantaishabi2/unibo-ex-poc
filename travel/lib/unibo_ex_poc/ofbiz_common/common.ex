defmodule UniboExPoc.Ofbiz.Common do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Ofbiz.Common.DataSource
    resource UniboExPoc.Ofbiz.Common.DataSourceType
<<<<<<< Updated upstream
=======
    resource UniboExPoc.Ofbiz.Common.DataSourceType.Version
>>>>>>> Stashed changes
    resource UniboExPoc.Ofbiz.Common.Enumeration
    resource UniboExPoc.Ofbiz.Common.EnumerationType
<<<<<<< Updated upstream
    resource UniboExPoc.Ofbiz.Common.Geo
    resource UniboExPoc.Ofbiz.Common.GeoType
=======
    resource UniboExPoc.Ofbiz.Common.EnumerationType.Version
    resource UniboExPoc.Ofbiz.Common.Geo
    resource UniboExPoc.Ofbiz.Common.Geo.Version
    resource UniboExPoc.Ofbiz.Common.GeoType
    resource UniboExPoc.Ofbiz.Common.GeoType.Version
>>>>>>> Stashed changes
  end
end
