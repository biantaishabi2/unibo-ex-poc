# Workflow: maintenance_stage_maintain_flow — 维护阶段维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Maintenance.MaintenanceStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_stages"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_maintenance_stage

    queries do
      get :get_maintenance_maintenance_stage, :read
      list :list_maintenance_maintenance_stages, :read
    end

    mutations do
      create :create_maintenance_maintenance_stage, :create
      update :update_maintenance_maintenance_stage, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      default 0
      public? true
    end
    attribute :fold, :boolean do
      default false
      public? true
    end
    attribute :done, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :maintenance_requests, UniboV4.Maintenance.MaintenanceRequest do
      public? true
      destination_attribute :stage_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :sequence, :fold, :done]
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
      accept [:name, :sequence, :fold, :done]
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
