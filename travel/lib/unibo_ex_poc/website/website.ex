defmodule UniboExPoc.Website do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Website.WebSite
    resource UniboExPoc.Website.WebSite.Version
    resource UniboExPoc.Website.WebPage
    resource UniboExPoc.Website.WebPage.Version
    resource UniboExPoc.Website.Menu
    resource UniboExPoc.Website.MenuTranslation
    resource UniboExPoc.Website.Menu.Version
    resource UniboExPoc.Website.Company
  end
end
