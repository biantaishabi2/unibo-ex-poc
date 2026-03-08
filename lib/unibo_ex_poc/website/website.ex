defmodule UniboV4.Website do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Website.WebSite
    resource UniboV4.Website.WebSite.Version
    resource UniboV4.Website.WebPage
    resource UniboV4.Website.WebPage.Version
    resource UniboV4.Website.Menu
    resource UniboV4.Website.MenuTranslation
    resource UniboV4.Website.Menu.Version
    resource UniboV4.Website.Party
  end
end
