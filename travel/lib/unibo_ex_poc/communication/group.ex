defmodule UniboExPoc.Communication.Group do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "权限组占位实体（用于 channel 的 group_public/group_ids 关系）"
  end

  postgres do
    table "communication_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :communication_group

    queries do
      get :get_communication_group, :read
      list :list_communication_groups, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string, public?: true
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
