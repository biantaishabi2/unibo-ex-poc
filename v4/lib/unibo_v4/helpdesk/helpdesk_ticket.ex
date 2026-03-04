# Workflow: ticket_lifecycle — 工单生命周期（创建→分配→处理→解决→关闭）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> assign
#   create --> change_stage
#   create --> update_priority
#   create --> plan_intervention
#   create --> archive
#   assign --> change_stage
#   assign --> resolve
#   assign --> update_priority
#   assign --> plan_intervention
#   assign --> archive
#   change_stage --> change_stage
#   change_stage --> resolve
#   change_stage --> close
#   change_stage --> reopen
#   change_stage --> update_priority
#   change_stage --> plan_intervention
#   resolve --> close
#   resolve --> reopen
#   close --> [*]
#   reopen --> assign
#   reopen --> change_stage
#   reopen --> resolve
#   reopen --> update_priority
#   archive --> [*]
#   update_priority --> change_stage
#   update_priority --> resolve
#   update_priority --> close
#   plan_intervention --> change_stage
#   plan_intervention --> resolve
#   plan_intervention --> close
# ```
defmodule UniboV4.Helpdesk.HelpdeskTicket do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Helpdesk.HelpdeskTicket.Notifier]

  postgres do
    table "helpdesk_tickets"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :priority, :atom do
      allow_nil? false
      constraints one_of: [:low, :normal, :high, :urgent]
      default :low
      public? true
    end
    attribute :kanban_state, :atom do
      allow_nil? false
      constraints one_of: [:normal, :blocked, :done]
      default :normal
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :color, :integer do
      allow_nil? false
      default 0
      public? true
    end
    attribute :email_cc, :string, public?: true
    attribute :source_channel, :atom do
      constraints one_of: [:email, :web_form, :portal, :sales_order, :live_chat, :manual]
      public? true
    end
    attribute :create_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :assign_date, :utc_datetime, public?: true
    attribute :close_date, :utc_datetime, public?: true
    attribute :date_last_stage_update, :utc_datetime, public?: true
    attribute :sla_deadline, :utc_datetime, public?: true
    attribute :priority_update_date, :utc_datetime, public?: true
    attribute :field_service_task_count, :integer do
      allow_nil? false
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :team, UniboV4.Helpdesk.HelpdeskTeam do
      public? true
      allow_nil? false
    end
    belongs_to :stage, UniboV4.Helpdesk.HelpdeskStage do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Helpdesk.User do
      public? true
    end
    belongs_to :partner, UniboV4.Helpdesk.Partner do
      public? true
    end
    belongs_to :ticket_type, UniboV4.Helpdesk.HelpdeskTicketType do
      public? true
    end
    belongs_to :sales_order, UniboV4.Helpdesk.SalesOrder do
      public? true
    end
    belongs_to :created_by, UniboV4.Helpdesk.User do
      public? true
    end
    has_many :sla_status_ids, UniboV4.Helpdesk.HelpdeskSLAStatus do
      public? true
      destination_attribute :ticket_id
    end
    has_many :timesheet_ids, UniboV4.Helpdesk.TimesheetEntry do
      public? true
    end
    has_many :field_service_tasks, UniboV4.Helpdesk.FieldServiceOrder do
      public? true
    end
    has_many :rating_ids, UniboV4.Helpdesk.Rating do
      public? true
    end
    many_to_many :tag_ids, UniboV4.Helpdesk.HelpdeskTag do
      public? true
      through UniboV4.Helpdesk.HelpdeskTicketTagLink
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :priority, :source_channel, :email_cc]
      argument :team_id, :uuid, allow_nil?: false
      argument :stage_id, :uuid, allow_nil?: false
      argument :ticket_type_id, :uuid
      argument :partner_id, :uuid
      argument :sales_order_id, :uuid
      change manage_relationship(:team_id, :team, type: :append, on_lookup: :relate)
      change manage_relationship(:stage_id, :stage, type: :append, on_lookup: :relate)
      validate present(:name)
      # message: "工单标题必填"
      validate present(:team)
      # message: "必须指定服务团队"
      validate present(:stage)
      # message: "必须指定阶段"
      change relate_actor(:created_by)
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect callback
      # TODO: 不支持的 change effect callback
      # TODO: 不支持的 change effect callback
      # TODO: 不支持的 change effect callback
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :assign do
      accept []
      argument :user_id, :uuid, allow_nil?: false
      change set_attribute(:assign_date, &DateTime.utc_now/0)
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
      accept []
      argument :stage_id, :uuid, allow_nil?: false
      change set_attribute(:date_last_stage_update, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect callback
      # TODO: 不支持的 change effect callback
      # TODO: 不支持的 change effect callback
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
    update :resolve do
      accept []
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
    update :close do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:close_date, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect callback
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
    update :reopen do
      accept []
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
    update :archive do
      accept []
      change set_attribute(:active, false)
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
    update :update_priority do
      accept [:priority]
      change set_attribute(:priority_update_date, &DateTime.utc_now/0)
      # TODO: 不支持的 change effect callback
      # TODO: 不支持的 change effect callback
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
    update :plan_intervention do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    identity :unique_ticket_name_team, [:name, :team_id]
  end

end
