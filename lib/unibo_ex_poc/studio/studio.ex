defmodule UniboV4.Studio do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Studio.CustomModel
    resource UniboV4.Studio.CustomModel.Version
    resource UniboV4.Studio.CustomField
    resource UniboV4.Studio.CustomField.Version
    resource UniboV4.Studio.CustomView
    resource UniboV4.Studio.CustomView.Version
    resource UniboV4.Studio.AutomationRule
    resource UniboV4.Studio.AutomationRule.Version
    resource UniboV4.Studio.App
    resource UniboV4.Studio.App.Version
    resource UniboV4.Studio.Party
  end
end
