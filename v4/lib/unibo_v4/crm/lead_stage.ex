defmodule UniboV4.CRM.LeadStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.CRM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "crm_lead_stages"
    repo UniboV4.Repo
  end

  graphql do
    type :crm_lead_stage

    queries do
      get :get_crm_lead_stage, :read
      list :list_crm_lead_stages, :read
    end

    mutations do
      create :create_crm_lead_stage, :create
      update :update_crm_lead_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
    end
    attribute :is_won, :boolean do
      default false
      public? true
    end
    attribute :fold, :boolean do
      default false
      public? true
    end
    attribute :probability, :decimal, public?: true
    attribute :requirements, :string, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :team, UniboV4.CRM.SalesTeam do
      public? true
    end
    has_many :leads, UniboV4.CRM.Lead do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :is_won, :fold, :probability, :requirements, :description]
      argument :team_id, :uuid
      validate present(:name)
      validate present(:sequence)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :sequence, :is_won, :fold, :probability, :requirements, :description]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
