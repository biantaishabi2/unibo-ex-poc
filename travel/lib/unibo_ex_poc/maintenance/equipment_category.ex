# Workflow: equipment_category_maintain_flow — 设备分类维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Maintenance.EquipmentCategory do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "设备分类，支持邮件别名自动创建维护请求，删除保护"
  end

  postgres do
    table "maintenance_equipment_categories"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_equipment_category

    queries do
      get :get_maintenance_equipment_category, :read
      list :list_maintenance_equipment_categorys, :read
    end

    mutations do
      create :create_maintenance_equipment_category, :create
      update :update_maintenance_equipment_category, :update
      destroy :delete_maintenance_equipment_category, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "分类名称"
    end
    attribute :alias_name, :string do
      public? true
      description "邮件别名，收到邮件时自动在该分类下创建维护请求"
    end
    attribute :maintenance_count, :integer do
      public? true
      description "该分类下维护请求总数"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :equipment_list, UniboExPoc.Maintenance.Equipment do
      public? true
      destination_attribute :category_ref_id
    end
    has_many :maintenance_requests, UniboExPoc.Maintenance.MaintenanceRequest do
      public? true
      destination_attribute :category_id
    end
    belongs_to :technician, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :technician_party_id
    end
    belongs_to :company, UniboExPoc.Maintenance.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :alias_name]
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:name)
      change UniboExPoc.Maintenance.Changes.EquipmentCategory.CreateCall1
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :alias_name]
      change UniboExPoc.Maintenance.Changes.EquipmentCategory.UpdateCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate {UniboExPoc.Maintenance.Validations.EquipmentCategory.CompanyMember, []}
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:equipment_list, :maintenance_requests]
  end

end
