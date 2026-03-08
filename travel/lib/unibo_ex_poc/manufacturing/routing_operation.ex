# Workflow: routing_operation_maintenance_flow — 工艺路线创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Manufacturing.RoutingOperation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工艺路线/工序定义"
  end

  postgres do
    table "manufacturing_routing_operations"
    repo UniboExPoc.Repo
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
      description "工艺路线编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      allow_nil? false
      public? true
      description "工序顺序"
    end
    attribute :standard_time_hours, :decimal do
      public? true
      description "标准工时"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :work_center, UniboExPoc.Manufacturing.WorkCenter do
      public? true
    end
    belongs_to :bom, UniboExPoc.Manufacturing.BillOfMaterials do
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :standard_time_hours, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_routing_code, [:routing_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
