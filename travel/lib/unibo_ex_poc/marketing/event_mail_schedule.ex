# Workflow: event_mail_schedule_maintain_flow — 活动邮件计划维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Marketing.EventMailSchedule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "活动邮件计划（订阅确认/提醒）"
  end

  postgres do
    table "marketing_event_mail_schedules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_event_mail_schedule

    queries do
      get :get_marketing_event_mail_schedule, :read
      list :list_marketing_event_mail_schedules, :read
    end

    mutations do
      create :create_marketing_event_mail_schedule, :create
      update :update_marketing_event_mail_schedule, :update
      destroy :delete_marketing_event_mail_schedule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :interval_type, :atom do
      constraints one_of: [:after_sub, :before_event, :after_event]
      public? true
      description "邮件触发类型"
    end
    attribute :interval_nbr, :integer do
      default 0
      public? true
      description "间隔数值"
    end
    attribute :interval_unit, :atom do
      constraints one_of: [:now, :hours, :days, :weeks]
      default &DateTime.utc_now/0
      public? true
      description "间隔单位"
    end
    attribute :template_ref, :string do
      public? true
      description "邮件模板引用"
    end
    attribute :mail_done, :boolean do
      default false
      public? true
      description "是否已发送"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :event, UniboExPoc.Marketing.Event do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:interval_type, :interval_nbr, :interval_unit, :template_ref]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:interval_type)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:interval_type, :interval_nbr, :interval_unit, :template_ref]
      change UniboExPoc.Marketing.Changes.EventMailSchedule.UpdateCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
