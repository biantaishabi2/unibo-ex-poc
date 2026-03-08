defmodule UniboV4.Knowledge.Group do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域用户组占位实体"
  end

  postgres do
    table "knowledge_groups"
    repo UniboV4.Repo
  end

  graphql do
    type :knowledge_group

    queries do
      get :get_knowledge_group, :read
      list :list_knowledge_groups, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
