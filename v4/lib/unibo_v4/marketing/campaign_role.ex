defmodule UniboV4.Marketing.CampaignRole do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "campaign_roles"
    repo UniboV4.Repo
  end

  graphql do
    type :campaign_role

    queries do
      get :get_campaign_role, :read
      list :list_campaign_roles, :read
    end

    mutations do
      create :create_campaign_role, :create
      destroy :delete_campaign_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string, allow_nil?: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboV4.Marketing.Campaign do
      allow_nil? false
        public? true
    end
    belongs_to :person, UniboV4.Accounts.User do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:role]
      argument :campaign_id, :uuid, allow_nil?: false
      argument :person_id, :uuid, allow_nil?: false
      change manage_relationship(:campaign_id, :campaign, type: :append, on_lookup: :relate)
      change manage_relationship(:person_id, :person, type: :append, on_lookup: :relate)
      validate present(:role)
    end
  end

end
