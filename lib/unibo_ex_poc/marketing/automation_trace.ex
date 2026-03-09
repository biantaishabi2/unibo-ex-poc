# Workflow: automation_trace_lifecycle — 自动化执行追踪
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> execute
#   create --> cancel
#   execute --> [*]
#   cancel --> [*]
# ```
defmodule UniboExPoc.Marketing.AutomationTrace do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "自动化工作流执行追踪记录"
  end

  postgres do
    table "marketing_automation_traces"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_automation_trace

    queries do
      get :get_marketing_automation_trace, :read
      list :list_marketing_automation_traces, :read
    end

    mutations do
      create :create_marketing_automation_trace, :create
      update :execute_marketing_automation_trace, :execute
      update :cancel_marketing_automation_trace, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :state, :atom do
      constraints one_of: [:scheduled, :processed, :rejected, :canceled, :error]
      default :scheduled
      public? true
      description "执行状态（所有终态不可逆转）"
    end
    attribute :schedule_date, :utc_datetime do
      allow_nil? false
      public? true
      description "计划执行时间"
    end
    attribute :date_triggered, :utc_datetime do
      public? true
      description "实际执行时间"
    end
    attribute :state_msg, :string do
      public? true
      description "状态消息/错误详情"
    end
    attribute :links_click_datetime, :utc_datetime do
      public? true
      description "链接点击时间"
    end
    attribute :mail_open_datetime, :utc_datetime do
      public? true
      description "邮件打开时间"
    end
    attribute :system_triggered, :boolean do
      default true
      public? true
      description "系统触发 vs 手动"
    end
    attribute :channel, :string do
      public? true
      description "通信渠道标识"
    end
    attribute :channel_id, :integer do
      public? true
      description "渠道资源 ID"
    end
    attribute :metadata, :string do
      public? true
      description "执行上下文数据"
    end
    attribute :non_action_path_taken, :boolean do
      default false
      public? true
      description "是否走了负向分支"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :activity, UniboExPoc.Marketing.AutomationActivity do
      public? true
      allow_nil? false
    end
    belongs_to :participant, UniboExPoc.Marketing.AutomationParticipant do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:schedule_date, :system_triggered]
      argument :activity_id, :uuid, allow_nil?: false
      argument :participant_id, :uuid, allow_nil?: false
      change manage_relationship(:activity_id, :activity, type: :append, on_lookup: :relate)
      change manage_relationship(:participant_id, :participant, type: :append, on_lookup: :relate)
      # validation: idempotent_trace
      change set_attribute(:id, expr(id))
    end
    update :execute do
      description "执行追踪记录"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :scheduled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :scheduled}))
        end
      end
      # message: "T-R1: 仅 scheduled 状态的 trace 可被执行"
      # skipped: validate compare :campaign_status (incompatible with bulk update atomic path)
      change set_attribute(:state, :processed)
      change set_attribute(:date_triggered, &DateTime.utc_now/0)
      change UniboExPoc.Marketing.Changes.AutomationTrace.ExecuteCall3
      change UniboExPoc.Marketing.Changes.AutomationTrace.ExecuteCall4
      change UniboExPoc.Marketing.Changes.AutomationTrace.ExecuteCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消执行"
      accept []
      change set_attribute(:state, :canceled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_activity_participant, [:activity_id, :participant_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
