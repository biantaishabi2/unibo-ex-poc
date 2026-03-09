# Workflow: maintenance_schedule_maintain_flow — 预防性维护计划维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Maintenance.MaintenanceSchedule do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "预防性维护计划"
  end

  postgres do
    table "maintenance_schedules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_maintenance_schedule

    queries do
      get :get_maintenance_maintenance_schedule, :read
      list :list_maintenance_maintenance_schedules, :read
    end

    mutations do
      create :create_maintenance_maintenance_schedule, :create
      update :update_maintenance_maintenance_schedule, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :schedule_code, :string do
      allow_nil? false
      public? true
      description "计划编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :frequency, :atom do
      allow_nil? false
      constraints one_of: [:daily, :weekly, :monthly, :quarterly, :yearly]
      public? true
      description "频率"
    end
    attribute :next_due_date, :date do
      allow_nil? false
      public? true
      description "下次执行日期"
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboExPoc.Maintenance.Equipment do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:schedule_code, :name, :frequency, :next_due_date, :description]
      argument :equipment_id, :uuid, allow_nil?: false
      change manage_relationship(:equipment_id, :equipment, type: :append, on_lookup: :relate)
      validate present(:schedule_code)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :frequency, :next_due_date, :is_active, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_schedule_code, [:schedule_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
