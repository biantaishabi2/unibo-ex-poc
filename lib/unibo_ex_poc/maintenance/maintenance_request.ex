# Workflow: maintenance_request_lifecycle — 维护请求生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> change_stage
#   create --> cancel
#   update --> change_stage
#   update --> cancel
#   change_stage --> change_stage
#   change_stage --> cancel
#   cancel --> [*]
# ```
defmodule UniboExPoc.Maintenance.MaintenanceRequest do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Maintenance.MaintenanceRequest.Notifier]

  resource do
    description "维护请求，支持阶段驱动看板和预防性维护自动克隆调度"
  end

  postgres do
    table "maintenance_requests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_maintenance_request

    queries do
      get :get_maintenance_maintenance_request, :read
      list :list_maintenance_maintenance_requests, :read
    end

    mutations do
      create :create_maintenance_maintenance_request, :create
      update :update_maintenance_maintenance_request, :update
      update :change_stage_maintenance_maintenance_request, :change_stage
      update :cancel_maintenance_maintenance_request, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :request_number, :string do
      allow_nil? false
      public? true
      description "请求编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "请求描述"
    end
    attribute :maintenance_type, :atom do
      allow_nil? false
      constraints one_of: [:corrective, :preventive]
      public? true
      description "维护类型（纠正性/预防性）"
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1", :"2", :"3"]
      default :"0"
      public? true
      description "优先级，3=高"
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
      description "看板状态"
    end
    attribute :request_date, :date do
      allow_nil? false
      default &DateTime.utc_now/0
      public? true
      description "提交日期"
    end
    attribute :schedule_date, :utc_datetime do
      public? true
      description "计划执行日期"
    end
    attribute :close_date, :date do
      public? true
      description "完成日期，进入 done 阶段时自动设置"
    end
    attribute :duration, :float do
      public? true
      description "预计工时"
    end
    attribute :archive, :boolean do
      default false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    attribute :repeat_interval, :integer do
      default 1
      public? true
      description "重复间隔"
    end
    attribute :repeat_unit, :atom do
      constraints one_of: [:day, :week, :month, :year]
      default :month
      public? true
      description "重复单位"
    end
    attribute :repeat_type, :atom do
      constraints one_of: [:forever, :until]
      default :forever
      public? true
      description "重复类型"
    end
    attribute :repeat_until, :date do
      public? true
      description "重复截止日期，当 repeat_type == until 时必填"
    end
    attribute :recurring_maintenance, :boolean do
      public? true
      description "是否周期性维护"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboExPoc.Maintenance.Equipment do
      public? true
    end
    belongs_to :category, UniboExPoc.Maintenance.EquipmentCategory do
      public? true
    end
    belongs_to :stage, UniboExPoc.Maintenance.MaintenanceStage do
      public? true
      allow_nil? false
    end
    belongs_to :technician, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :technician_party_id
    end
    belongs_to :owner, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :owner_party_id
    end
    belongs_to :maintenance_team, UniboExPoc.Maintenance.MaintenanceTeam do
      public? true
    end
    belongs_to :company, UniboExPoc.Maintenance.Party do
      public? true
      allow_nil? false
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:request_number, :name, :maintenance_type, :priority, :description, :request_date, :schedule_date, :duration, :notes, :repeat_interval, :repeat_unit, :repeat_type, :repeat_until]
      argument :equipment_id, :uuid
      argument :category_id, :uuid
      argument :stage_id, :uuid, allow_nil?: false
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:request_number)
      validate present(:name)
      validate present(:repeat_until)
      # message: "当重复类型为 until 时，截止日期必填"
      change relate_actor(:owner)
      change UniboExPoc.Maintenance.Changes.MaintenanceRequest.CreateCall4
      change UniboExPoc.Maintenance.Changes.MaintenanceRequest.CreateCall9
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :priority, :kanban_state, :schedule_date, :duration, :notes, :archive]
      # skipped: validate present :repeat_until (incompatible with bulk update atomic path)
      change UniboExPoc.Maintenance.Changes.MaintenanceRequest.UpdateCall9
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :change_stage do
      description "变更阶段（看板拖拽）"
      accept [:stage_id]
      # skipped: validate present :repeat_until (incompatible with bulk update atomic path)
      change set_attribute(:kanban_state, :normal)
      change set_attribute(:close_date, &DateTime.utc_now/0)
      change set_attribute(:close_date, nil)
      change UniboExPoc.Maintenance.Changes.MaintenanceRequest.ChangeStageCall8
      change UniboExPoc.Maintenance.Changes.MaintenanceRequest.ChangeStageCall9
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消请求"
      accept []
      # skipped: validate present :repeat_until (incompatible with bulk update atomic path)
      change UniboExPoc.Maintenance.Changes.MaintenanceRequest.CancelCall9
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_request_number, [:request_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
