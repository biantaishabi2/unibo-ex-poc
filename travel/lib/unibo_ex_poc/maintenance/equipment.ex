# Workflow: equipment_lifecycle — 设备生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> retire
#   update --> retire
#   retire --> [*]
# ```
defmodule UniboExPoc.Maintenance.Equipment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "设备，支持 MTBF/MTTR 可靠性指标计算"
  end

  postgres do
    table "maintenance_equipments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_equipment

    queries do
      get :get_maintenance_equipment, :read
      list :list_maintenance_equipments, :read
    end

    mutations do
      create :create_maintenance_equipment, :create
      update :update_maintenance_equipment, :update
      update :retire_maintenance_equipment, :retire
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :asset_code, :string do
      allow_nil? false
      public? true
      description "设备编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "设备名称"
    end
    attribute :serial_number, :string do
      public? true
      description "序列号"
    end
    attribute :status, :atom do
      constraints one_of: [:operational, :maintenance, :retired]
      default :operational
      public? true
    end
    attribute :category, :string do
      public? true
      description "设备分类"
    end
    attribute :location, :string do
      public? true
      description "存放位置"
    end
    attribute :purchase_date, :date, public?: true
    attribute :warranty_expiry_date, :date, public?: true
    attribute :effective_date, :date do
      public? true
      description "MTBF 计算基线日期"
    end
    attribute :notes, :string, public?: true
    attribute :maintenance_count, :integer do
      public? true
      description "维护请求总数"
    end
    attribute :maintenance_open_count, :integer do
      public? true
      description "未完成、未归档请求数"
    end
    attribute :mttr, :decimal do
      public? true
      description "平均修复时间（天），仅基于 corrective + done 状态的请求"
    end
    attribute :mtbf, :decimal do
      public? true
      description "平均故障间隔（天），仅基于 corrective + done 状态的请求"
    end
    attribute :estimated_next_failure, :date do
      public? true
      description "预计下次故障日期"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :maintenance_requests, UniboExPoc.Maintenance.MaintenanceRequest do
      public? true
    end
    belongs_to :category_ref, UniboExPoc.Maintenance.EquipmentCategory do
      public? true
    end
    belongs_to :owner, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :owner_party_id
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
    belongs_to :maintenance_team, UniboExPoc.Maintenance.MaintenanceTeam do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:asset_code, :name, :category, :location, :purchase_date, :warranty_expiry_date, :serial_number, :effective_date, :notes]
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:asset_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :status, :category, :location, :effective_date, :notes]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :retire do
      description "报废设备"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:operational, :maintenance] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:operational, :maintenance]}))
        end
      end
      # message: "只有运行中或维护中状态可以报废"
      change set_attribute(:status, :retired)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate {UniboExPoc.Maintenance.Validations.Equipment.CompanyIsolation, []}
  end

  identities do
    identity :unique_asset_code, [:asset_code]
    identity :unique_serial_number, [:serial_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
