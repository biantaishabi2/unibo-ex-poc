# Workflow: automation_rule_lifecycle — 自动化规则生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> execute
#   create --> destroy
#   update --> execute
#   update --> destroy
#   execute --> update
#   execute --> execute
#   destroy --> [*]
# ```
defmodule UniboExPoc.Studio.AutomationRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Studio,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "事件驱动的自动化规则，支持 8 种触发类型和 8 种动作类型"
  end

  postgres do
    table "studio_automation_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :studio_automation_rule

    queries do
      get :get_studio_automation_rule, :read
      list :list_studio_automation_rules, :read
    end

    mutations do
      create :create_studio_automation_rule, :create
      update :update_studio_automation_rule, :update
      update :execute_studio_automation_rule, :execute
      destroy :delete_studio_automation_rule, :destroy
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
    attribute :trigger_type, :atom do
      allow_nil? false
      constraints one_of: [:on_create, :on_write, :on_create_or_write, :on_delete, :on_time, :on_condition, :on_webhook, :manual]
      public? true
      description "触发类型，共 8 种"
    end
    attribute :trigger_config, :string do
      allow_nil? false
      public? true
      description "触发配置，结构随 trigger_type 变化"
    end
    attribute :condition_domain, :string do
      public? true
      description "前置过滤条件（Domain 表达式），触发后、动作前求值"
    end
    attribute :action_type, :atom do
      allow_nil? false
      constraints one_of: [:update_record, :create_record, :send_email, :send_notification, :execute_code, :call_webhook, :add_followers, :chain_automation]
      public? true
      description "动作类型，共 8 种"
    end
    attribute :action_config, :string do
      allow_nil? false
      public? true
      description "动作配置，结构随 action_type 变化"
    end
    attribute :sequence, :integer do
      public? true
      description "多规则执行顺序"
    end
    attribute :is_active, :boolean do
      default false
      public? true
      description "是否启用"
    end
    attribute :last_run_at, :utc_datetime do
      public? true
      description "最后执行时间"
    end
    attribute :run_count, :integer do
      default 0
      public? true
      description "执行次数"
    end
    attribute :error_count, :integer do
      default 0
      public? true
      description "错误次数"
    end
    attribute :last_error, :string do
      public? true
      description "最后错误信息"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :model, UniboExPoc.Studio.CustomModel do
      public? true
      allow_nil? false
      attribute_type :integer
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :trigger_type, :trigger_config, :condition_domain, :action_type, :action_config, :sequence, :is_active]
      argument :model_id, :integer, allow_nil?: false
      change manage_relationship(:model_id, :model, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:trigger_type)
      validate present(:action_type)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :trigger_type, :trigger_config, :condition_domain, :action_type, :action_config, :sequence, :is_active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :execute do
      description "手动触发执行规则"
      accept []
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
