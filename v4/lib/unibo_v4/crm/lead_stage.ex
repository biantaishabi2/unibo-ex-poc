defmodule UniboV4.CRM.LeadStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "lead_stages"
    repo UniboV4.Repo
  end

  graphql do
    type :lead_stage

    queries do
      get :get_lead_stage, :read
      list :list_lead_stages, :read
    end

    mutations do
      create :create_lead_stage, :create
      update :update_lead_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :sequence, :integer, allow_nil?: false
    attribute :probability, :decimal
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :probability, :description]
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :sequence, :probability, :description]
    end
  end

end
