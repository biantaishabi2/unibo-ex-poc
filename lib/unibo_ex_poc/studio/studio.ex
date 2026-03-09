defmodule UniboExPoc.Studio do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Studio.CustomModel
    resource UniboExPoc.Studio.CustomModel.Version
    resource UniboExPoc.Studio.CustomField
    resource UniboExPoc.Studio.CustomField.Version
    resource UniboExPoc.Studio.CustomView
    resource UniboExPoc.Studio.CustomView.Version
    resource UniboExPoc.Studio.AutomationRule
    resource UniboExPoc.Studio.AutomationRule.Version
    resource UniboExPoc.Studio.App
    resource UniboExPoc.Studio.App.Version
    resource UniboExPoc.Studio.Party
  end
end
