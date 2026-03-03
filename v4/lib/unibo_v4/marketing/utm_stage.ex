# Workflow: utm_stage_maintain_flow — UTM 阶段维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Marketing.UtmStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_utm_stages"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_utm_stage

    queries do
      get :get_marketing_utm_stage, :read
      list :list_marketing_utm_stages, :read
    end

    mutations do
      create :create_marketing_utm_stage, :create
      update :update_marketing_utm_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      default 1
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :campaigns, UniboV4.Marketing.UtmCampaign do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence]
      validate present(:name)
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
      accept [:name, :sequence]
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

  identities do
    identity :unique_utm_stage_name, [:name]
  end

end
