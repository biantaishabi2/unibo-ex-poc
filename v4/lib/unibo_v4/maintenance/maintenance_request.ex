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
defmodule UniboV4.Maintenance.MaintenanceRequest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Maintenance.MaintenanceRequest.Notifier]

  postgres do
    table "maintenance_requests"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :request_number, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :maintenance_type, :atom do
      allow_nil? false
      constraints one_of: [:corrective, :preventive]
      public? true
    end
    attribute :priority, :atom do
      constraints one_of: [:"0", :"1", :"2", :"3"]
      default :"0"
      public? true
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
    end
    attribute :request_date, :date do
      allow_nil? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :schedule_date, :utc_datetime, public?: true
    attribute :close_date, :date, public?: true
    attribute :duration, :float, public?: true
    attribute :archive, :boolean do
      default false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :notes, :string, public?: true
    attribute :repeat_interval, :integer do
      default 1
      public? true
    end
    attribute :repeat_unit, :atom do
      constraints one_of: [:day, :week, :month, :year]
      default :month
      public? true
    end
    attribute :repeat_type, :atom do
      constraints one_of: [:forever, :until]
      default :forever
      public? true
    end
    attribute :repeat_until, :date, public?: true
    attribute :recurring_maintenance, :boolean, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboV4.Maintenance.Equipment do
      public? true
    end
    belongs_to :category, UniboV4.Maintenance.EquipmentCategory do
      public? true
    end
    belongs_to :stage, UniboV4.Maintenance.MaintenanceStage do
      public? true
      allow_nil? false
    end
    belongs_to :technician, UniboV4.Maintenance.User do
      public? true
    end
    belongs_to :owner, UniboV4.Maintenance.User do
      public? true
    end
    belongs_to :maintenance_team, UniboV4.Maintenance.MaintenanceTeam do
      public? true
    end
    belongs_to :company, UniboV4.Maintenance.Company do
      public? true
      allow_nil? false
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
      # TODO: 不支持的 action 内校验规则 conditional_required
      change relate_actor(:owner)
      # TODO: 不支持的 change effect auto_fill
      # TODO: 不支持的 change effect auto_fill
      # TODO: 不支持的 change effect subscribe_followers
      # TODO: 不支持的 change effect manage_activity
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
      accept [:name, :priority, :kanban_state, :schedule_date, :duration, :notes, :archive]
      # skipped: validate conditional_required :repeat_until (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect manage_activity
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
    update :change_stage do
      # skipped: validate conditional_required :repeat_until (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect reset_attribute
      change set_attribute(:close_date, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect clear_attribute
      # TODO: 不支持的 change effect clone_preventive
      # TODO: 不支持的 change effect manage_activity
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
    update :cancel do
      accept []
      # skipped: validate conditional_required :repeat_until (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect manage_activity
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
    identity :unique_request_number, [:request_number]
  end

end
