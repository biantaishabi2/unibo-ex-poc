defmodule UniboExPoc.DataRecycle do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.DataRecycle.RecycleModel
    resource UniboExPoc.DataRecycle.RecycleModel.Version
    resource UniboExPoc.DataRecycle.RecycleRecord
    resource UniboExPoc.DataRecycle.RecycleRecord.Version
    resource UniboExPoc.DataRecycle.RecycleModelNotifyUser
    resource UniboExPoc.DataRecycle.RecycleModelNotifyUser.Version
    resource UniboExPoc.DataRecycle.Party
  end
end
