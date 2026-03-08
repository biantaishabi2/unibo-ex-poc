# Workflow: call_queue_lifecycle_flow — 呼叫队列创建、参数维护、坐席登入登出与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   login_agent --> [*]
#   logout_agent --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.CallQueue do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "呼叫队列，管理来电分配策略，支持 6 种振铃策略和溢出处理，支持坐席动态登入登出"
  end

  postgres do
    table "io_t_call_queues"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_call_queue

    queries do
      get :get_io_t_call_queue, :read
      list :list_io_t_call_queues, :read
    end

    mutations do
      create :create_io_t_call_queue, :create
      update :update_io_t_call_queue, :update
      update :login_agent_io_t_call_queue, :login_agent
      update :logout_agent_io_t_call_queue, :logout_agent
      destroy :delete_io_t_call_queue, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "队列名称（如 \"Sales\"、\"Support\"）"
    end
    attribute :ring_strategy, :atom do
      allow_nil? false
      constraints one_of: [:simultaneous, :round_robin, :least_recent, :random, :fewestcalls, :wrandom]
      default :simultaneous
      public? true
      description "振铃策略"
    end
    attribute :timeout_seconds, :integer do
      default 30
      public? true
      description "单次振铃超时"
    end
    attribute :max_wait_seconds, :integer do
      default 300
      public? true
      description "最大排队等待时间"
    end
    attribute :max_callers, :integer do
      default 20
      public? true
      description "队列最大容量"
    end
    attribute :voicemail_enabled, :boolean do
      default true
      public? true
      description "是否启用语音信箱"
    end
    attribute :overflow_action, :atom do
      constraints one_of: [:voicemail, :next_queue, :hangup, :callback]
      default :voicemail
      public? true
      description "溢出处理策略"
    end
    attribute :callback_enabled, :boolean do
      default false
      public? true
      description "是否支持回拨"
    end
    attribute :announce_position, :boolean do
      default true
      public? true
      description "播报排队位置"
    end
    attribute :announce_wait_time, :boolean do
      default false
      public? true
      description "播报预计等待时间"
    end
    attribute :wrapup_time_seconds, :integer do
      default 15
      public? true
      description "坐席挂断后整理时间"
    end
    attribute :sla_target_seconds, :integer do
      default 20
      public? true
      description "SLA 目标接听时间"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :available_agent_count, :integer, expr(count(members, query: [filter: expr(true)]))
    calculate :current_wait_count, :integer, expr(count(calls, query: [filter: expr(true)]))
    calculate :sla_percentage, :decimal, {UniboExPoc.IoT.Calculations.CallQueue.SlaPercentage, []}
    calculate :avg_wait_time, :integer, {UniboExPoc.IoT.Calculations.CallQueue.AvgWaitTime, []}
  end

  relationships do
    has_many :members, UniboExPoc.IoT.QueueMember do
      public? true
      destination_attribute :queue_id
    end
    has_many :calls, UniboExPoc.IoT.VoIPCall do
      public? true
      destination_attribute :queue_id
    end
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :music_on_hold, UniboExPoc.IoT.Media do
      public? true
      attribute_type :integer
    end
    has_many :incoming_numbers, UniboExPoc.IoT.IncomingNumber do
      public? true
      destination_attribute :queue_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :ring_strategy, :timeout_seconds, :max_wait_seconds, :max_callers, :voicemail_enabled, :overflow_action, :callback_enabled, :announce_position, :announce_wait_time, :music_on_hold_id, :wrapup_time_seconds, :sla_target_seconds, :org_id]
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:name)
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
      accept [:name, :ring_strategy, :timeout_seconds, :max_wait_seconds, :max_callers, :voicemail_enabled, :overflow_action, :callback_enabled, :announce_position, :announce_wait_time, :music_on_hold_id, :wrapup_time_seconds, :sla_target_seconds]
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
    update :login_agent do
      description "坐席动态登入队列"
      argument :agent_user_id, :integer, allow_nil?: false
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change UniboExPoc.IoT.Changes.CallQueue.LoginAgentCreateRelated1
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
    update :logout_agent do
      description "坐席动态登出队列"
      argument :agent_user_id, :integer, allow_nil?: false
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # cascade_destroy — 缺少 field，跳过
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

  validations do
    validate compare(:timeout_seconds, greater_than: 0)
    validate compare(:max_wait_seconds, greater_than: 0)
    validate compare(:max_callers, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:members, :calls, :incoming_numbers]
  end

end
