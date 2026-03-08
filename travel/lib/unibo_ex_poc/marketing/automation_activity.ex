# Workflow: automation_activity_maintain_flow — 自动化活动节点维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Marketing.AutomationActivity do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "工作流活动节点（DAG 有向无环图）"
  end

  postgres do
    table "marketing_automation_activities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_automation_activity

    queries do
      get :get_marketing_automation_activity, :read
      list :list_marketing_automation_activitys, :read
    end

    mutations do
      create :create_marketing_automation_activity, :create
      update :update_marketing_automation_activity, :update
      destroy :delete_marketing_automation_activity, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "活动名称"
    end
    attribute :activity_type, :atom do
      allow_nil? false
      constraints one_of: [:email, :sms, :server_action, :whatsapp]
      public? true
      description "活动类型"
    end
    attribute :trigger_type, :atom do
      allow_nil? false
      constraints one_of: [:begin, :activity_done, :mail_open, :mail_click, :mail_reply, :mail_not_open, :mail_bounce, :form_submit, :page_visit, :point_change, :stage_change]
      public? true
      description "触发方式"
    end
    attribute :decision_path, :atom do
      constraints one_of: [:yes, :no]
      public? true
      description "正向/负向分支（仅当 parent 为条件/决策触发类型时有效）"
    end
    attribute :trigger_interval, :integer do
      default 0
      public? true
      description "触发间隔数值"
    end
    attribute :trigger_interval_type, :atom do
      constraints one_of: [:hours, :days, :weeks, :months]
      default :hours
      public? true
      description "间隔单位"
    end
    attribute :trigger_mode, :atom do
      constraints one_of: [:immediate, :interval, :date, :optimized]
      default :interval
      public? true
      description "触发模式"
    end
    attribute :trigger_hour, :string do
      public? true
      description "限定发送时段"
    end
    attribute :trigger_restricted_days, {:array, :string} do
      public? true
      description "限定发送日（周几，整数数组）"
    end
    attribute :domain_filter, :string do
      public? true
      description "活动级额外筛选条件"
    end
    attribute :condition, :string do
      public? true
      description "条件表达式（高级模式）"
    end
    attribute :server_action_id, :uuid do
      public? true
      description "关联服务器动作"
    end
    attribute :email_template_id, :uuid do
      public? true
      description "关联邮件模板"
    end
    attribute :sms_template_id, :uuid do
      public? true
      description "关联短信模板"
    end
    attribute :variable_cost, :decimal do
      public? true
      description "单次执行可变成本"
    end
    attribute :expiry_duration, :integer do
      public? true
      description "过期时间（超过则跳过）"
    end
    attribute :expiry_duration_type, :atom do
      constraints one_of: [:hours, :days]
      public? true
      description "过期单位"
    end
    attribute :order, :integer do
      default 0
      public? true
      description "同级节点排序"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :campaign, UniboExPoc.Marketing.AutomationCampaign do
      public? true
      allow_nil? false
    end
    belongs_to :parent, UniboExPoc.Marketing.AutomationActivity do
      public? true
    end
    has_many :children, UniboExPoc.Marketing.AutomationActivity do
      public? true
      source_attribute :parent_id
      destination_attribute :parent_id
    end
    has_many :traces, UniboExPoc.Marketing.AutomationTrace do
      public? true
      source_attribute :parent_id
      destination_attribute :activity_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :activity_type, :trigger_type, :decision_path, :trigger_interval, :trigger_interval_type, :trigger_mode, :trigger_hour, :trigger_restricted_days, :domain_filter, :condition, :server_action_id, :email_template_id, :sms_template_id, :variable_cost, :expiry_duration, :expiry_duration_type, :order]
      argument :campaign_id, :uuid, allow_nil?: false
      argument :parent_id, :uuid
      change manage_relationship(:campaign_id, :campaign, type: :append, on_lookup: :relate)
      validate present(:name)
      # validation: no_dag_cycle
      # validation: decision_path_valid
      # validation: template_required_by_type
      # validation: mutual_exclusive_branches
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
      accept [:name, :activity_type, :trigger_type, :decision_path, :trigger_interval, :trigger_interval_type, :trigger_mode, :trigger_hour, :trigger_restricted_days, :domain_filter, :condition, :server_action_id, :email_template_id, :sms_template_id, :variable_cost, :expiry_duration, :expiry_duration_type, :order]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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

  archive do
    archive_related [:children, :traces]
  end

end
