# Workflow: service_type_maintain_flow — 服务类型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Maintenance.ServiceType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "统一类型系统，通过 category 字段区分合同类型与服务类型"
  end

  postgres do
    table "maintenance_service_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_service_type

    queries do
      get :get_maintenance_service_type, :read
      list :list_maintenance_service_types, :read
    end

    mutations do
      create :create_maintenance_service_type, :create
      update :update_maintenance_service_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称"
    end
    attribute :category, :atom do
      allow_nil? false
      constraints one_of: [:contract, :service]
      public? true
      description "类型分类，决定用于合同还是服务记录"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :category]
      validate present(:name)
      validate present(:category)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :category]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
