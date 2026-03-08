defmodule UniboV4.DataRecycle do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.DataRecycle.RecycleModel
    resource UniboV4.DataRecycle.RecycleModel.Version
    resource UniboV4.DataRecycle.RecycleRecord
    resource UniboV4.DataRecycle.RecycleRecord.Version
    resource UniboV4.DataRecycle.RecycleModelNotifyUser
    resource UniboV4.DataRecycle.RecycleModelNotifyUser.Version
    resource UniboV4.DataRecycle.Party
  end
end
