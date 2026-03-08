# Workflow: event_log_processing_flow — 事件日志写入与处理完成标记流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   mark_processed --> [*]
# ```
defmodule UniboExPoc.IoT.EventLog do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "IoT 事件日志，只追加写入，记录每个设备事件及规则处理结果，30 天自动清理"
  end

  postgres do
    table "io_t_event_logs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_event_log

    queries do
      get :get_io_t_event_log, :read
      list :list_io_t_event_logs, :read
    end

    mutations do
      create :create_io_t_event_log, :create
      update :mark_processed_io_t_event_log, :mark_processed
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :event_type, :string do
      allow_nil? false
      public? true
      description "事件类型（scan / measure / status_change / error / heartbeat）"
    end
    attribute :payload, :string do
      allow_nil? false
      public? true
      description "原始事件数据"
    end
    attribute :processed, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否已被规则引擎处理"
    end
    attribute :action_result, :atom do
      constraints one_of: [:success, :failed, :skipped, :cooldown]
      public? true
      description "处理结果"
    end
    attribute :action_error_message, :string do
      public? true
      description "失败时错误信息"
    end
    attribute :processing_time_ms, :integer do
      public? true
      description "处理耗时（毫秒）"
    end
    create_timestamp :created_at
  end

  calculations do
    calculate :is_error, :boolean, expr(action_result == failed)
    calculate :age_days, :integer, expr(datetime_diff_days("now", created_at))
  end

  relationships do
    belongs_to :device, UniboExPoc.IoT.IoTDevice do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :box, UniboExPoc.IoT.IoTBox do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :trigger_rule, UniboExPoc.IoT.TriggerRule do
      public? true
      attribute_type :integer
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:device_id, :box_id, :event_type, :payload]
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
      description "标记为已处理"
      primary? true
      accept [:trigger_rule_id, :action_result, :action_error_message, :processing_time_ms]
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
