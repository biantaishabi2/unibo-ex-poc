defmodule UniboV4.Knowledge.Group do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
