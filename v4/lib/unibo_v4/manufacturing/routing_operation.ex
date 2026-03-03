# Workflow: routing_operation_maintenance_flow — 工艺路线创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Manufacturing.RoutingOperation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "manufacturing_routing_operations"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_routing_operation

    queries do
      get :get_manufacturing_routing_operation, :read
      list :list_manufacturing_routing_operations, :read
    end

    mutations do
      create :create_manufacturing_routing_operation, :create
      update :update_manufacturing_routing_operation, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :routing_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
    end
    attribute :standard_time_hours, :decimal, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :work_center, UniboV4.Manufacturing.WorkCenter do
      public? true
    end
    belongs_to :bom, UniboV4.Manufacturing.BillOfMaterials do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:routing_code, :name, :sequence, :standard_time_hours, :description]
      validate present(:routing_code)
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
      accept [:name, :sequence, :standard_time_hours, :description]
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
    identity :unique_routing_code, [:routing_code]
  end

end
