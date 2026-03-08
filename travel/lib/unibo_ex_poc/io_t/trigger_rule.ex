# Workflow: trigger_rule_toggle_flow — 触发规则创建、维护与启停流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   activate --> [*]
#   deactivate --> [*]
# ```
defmodule UniboExPoc.IoT.TriggerRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "IoT 触发规则，当设备事件匹配时执行指定动作，支持冷却防抖和优先级排序"
  end

  postgres do
    table "io_t_trigger_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_trigger_rule

    queries do
      get :get_io_t_trigger_rule, :read
      list :list_io_t_trigger_rules, :read
    end

    mutations do
      create :create_io_t_trigger_rule, :create
      update :update_io_t_trigger_rule, :update
      update :activate_io_t_trigger_rule, :activate
      update :deactivate_io_t_trigger_rule, :deactivate
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
      description "规则名称"
    end
    attribute :description, :string do
      public? true
      description "人类可读描述"
    end
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:scan, :weight_stable, :button_press, :measurement, :temperature_alert]
      public? true
      description "事件类型"
    end
    attribute :condition, :string do
      public? true
      description "可选条件表达式（如 \"weight > 0.5kg\"）"
    end
    attribute :action_type, :atom do
      allow_nil? false
      constraints one_of: [:print_report, :create_record, :call_webhook, :update_field, :notify_user]
      public? true
      description "动作类型"
    end
    attribute :action_config, :string do
      allow_nil? false
      public? true
      description "动作配置（结构随 action_type 变化）"
    end
    attribute :is_active, :boolean do
      allow_nil? false
      default true
      public? true
      description "是否启用"
    end
    attribute :priority, :integer do
      default 10
      public? true
      description "执行优先级（越小越先）"
    end
    attribute :stop_on_match, :boolean do
      default false
      public? true
      description "命中后阻止后续低优先级规则"
    end
    attribute :cooldown_seconds, :integer do
      default 5
      public? true
      description "冷却时间（秒）"
    end
    attribute :last_triggered_at, :utc_datetime do
      public? true
      description "上次触发时间"
    end
    attribute :execution_count, :integer do
      default 0
      public? true
      description "累计成功次数"
    end
    attribute :error_count, :integer do
      default 0
      public? true
      description "累计失败次数"
    end
    attribute :error_action, :atom do
      constraints one_of: [:ignore, :retry_once, :notify_admin]
      default :notify_admin
      public? true
      description "失败处理策略"
    end
  end

  calculations do
    calculate :success_rate, :decimal, expr((execution_count / (execution_count + error_count)))
    calculate :is_in_cooldown, :boolean, expr(datetime_diff("now", last_triggered_at) < cooldown_seconds)
  end

  relationships do
    belongs_to :device, UniboExPoc.IoT.IoTDevice do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :event_logs, UniboExPoc.IoT.EventLog do
      public? true
      source_attribute :device_id
      destination_attribute :trigger_rule_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :device_id, :event_type, :condition, :action_type, :action_config, :is_active, :priority, :stop_on_match, :cooldown_seconds, :error_action]
      argument :device_id, :integer, allow_nil?: false
      change manage_relationship(:device_id, :device, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:device_id)
      validate present(:action_config)
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
      accept [:name, :description, :condition, :action_type, :action_config, :is_active, :priority, :stop_on_match, :cooldown_seconds, :error_action]
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
    update :activate do
      description "启用规则"
      accept []
      change set_attribute(:is_active, true)
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
    update :deactivate do
      description "停用规则"
      accept []
      change set_attribute(:is_active, false)
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
