# Workflow: event_log_processing_flow — 事件日志写入与处理完成标记流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   mark_processed --> [*]
# ```
defmodule UniboV4.IoT.EventLog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "io_t_event_logs"
    repo UniboV4.Repo
  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :event_type, :string do
      allow_nil? false
      public? true
    end
    attribute :payload, :string do
      allow_nil? false
      public? true
    end
    attribute :processed, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :action_result, :atom do
      constraints one_of: [:success, :failed, :skipped, :cooldown]
      public? true
    end
    attribute :action_error_message, :string, public?: true
    attribute :processing_time_ms, :integer, public?: true
    create_timestamp :created_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_error
    # TODO: 不支持的 calculation 表达式 :age_days
  end

  relationships do
    belongs_to :device, UniboV4.IoT.IoTDevice do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :box, UniboV4.IoT.IoTBox do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :trigger_rule, UniboV4.IoT.TriggerRule do
      public? true
      attribute_type :integer
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:event_type, :payload]
      argument :device_id, :integer, allow_nil?: false
      change manage_relationship(:device_id, :device, type: :append, on_lookup: :relate)
      argument :box_id, :integer, allow_nil?: false
      change manage_relationship(:box_id, :box, type: :append, on_lookup: :relate)
      validate present(:device_id)
      validate present(:event_type)
      validate present(:payload)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :mark_processed do
      accept [:action_result, :action_error_message, :processing_time_ms]
      change set_attribute(:processed, true)
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

end
