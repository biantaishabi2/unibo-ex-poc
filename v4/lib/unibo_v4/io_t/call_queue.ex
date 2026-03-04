# Workflow: call_queue_lifecycle_flow — 呼叫队列创建、参数维护与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.IoT.CallQueue do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "io_t_call_queues"
    repo UniboV4.Repo
  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :ring_strategy, :atom do
      allow_nil? false
      constraints one_of: [:simultaneous, :round_robin, :least_recent, :random, :fewestcalls, :wrandom]
      default :simultaneous
      public? true
    end
    attribute :timeout_seconds, :integer do
      default 30
      public? true
    end
    attribute :max_wait_seconds, :integer do
      default 300
      public? true
    end
    attribute :max_callers, :integer do
      default 20
      public? true
    end
    attribute :voicemail_enabled, :boolean do
      default true
      public? true
    end
    attribute :overflow_action, :atom do
      constraints one_of: [:voicemail, :next_queue, :hangup, :callback]
      default :voicemail
      public? true
    end
    attribute :callback_enabled, :boolean do
      default false
      public? true
    end
    attribute :announce_position, :boolean do
      default true
      public? true
    end
    attribute :announce_wait_time, :boolean do
      default false
      public? true
    end
    attribute :wrapup_time_seconds, :integer do
      default 15
      public? true
    end
    attribute :sla_target_seconds, :integer do
      default 20
      public? true
    end
  end

  calculations do
    calculate :available_agent_count, :integer, expr(count(members, query: [filter: expr(true)]))
    calculate :current_wait_count, :integer, expr(count(calls, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :sla_percentage
    # TODO: 不支持的 calculation 表达式 :avg_wait_time
  end

  relationships do
    has_many :members, UniboV4.IoT.QueueMember do
      public? true
      destination_attribute :queue_id
    end
    has_many :calls, UniboV4.IoT.VoIPCall do
      public? true
      destination_attribute :queue_id
    end
    belongs_to :org, UniboV4.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :music_on_hold, UniboV4.IoT.Media do
      public? true
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :ring_strategy, :timeout_seconds, :max_wait_seconds, :max_callers, :voicemail_enabled, :overflow_action, :callback_enabled, :announce_position, :announce_wait_time, :wrapup_time_seconds, :sla_target_seconds]
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
      accept [:name, :ring_strategy, :timeout_seconds, :max_wait_seconds, :max_callers, :voicemail_enabled, :overflow_action, :callback_enabled, :announce_position, :announce_wait_time, :wrapup_time_seconds, :sla_target_seconds]
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

end
