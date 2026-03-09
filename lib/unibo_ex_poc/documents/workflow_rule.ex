# Workflow: workflow_rule_execution_flow — 工作流规则配置、执行与回收流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   execute --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Documents.WorkflowRule do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "工作流动作规则，定义文档的自动化处理（条件匹配 + 执行动作）"
  end

  postgres do
    table "documents_workflow_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_workflow_rule

    queries do
      get :get_documents_workflow_rule, :read
      list :list_documents_workflow_rules, :read
    end

    mutations do
      create :create_documents_workflow_rule, :create
      update :update_documents_workflow_rule, :update
      update :execute_documents_workflow_rule, :execute
      destroy :delete_documents_workflow_rule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "动作名称（显示在 UI 按钮上）"
    end
    attribute :note, :string do
      public? true
      description "内部备注"
    end
    attribute :condition_type, :atom do
      allow_nil? false
      constraints one_of: [:criteria, :domain]
      public? true
      description "criteria=标准条件, domain=高级域表达式"
    end
    attribute :domain, :string do
      public? true
      description "condition_type=domain 时的高级过滤条件（JSON）"
    end
    attribute :create_model, :atom do
      constraints one_of: [:link_to_record, :vendor_bill, :customer_invoice, :vendor_refund, :customer_refund, :sign_direct, :sign_request, :product, :project_task]
      public? true
      description "创建业务记录类型"
    end
    attribute :activity_option, :atom do
      constraints one_of: [:nothing, :mark_done, :schedule]
      public? true
      description "活动处理方式"
    end
    attribute :activity_summary, :string do
      public? true
      description "活动摘要"
    end
    attribute :activity_date_deadline_range, :integer do
      public? true
      description "活动截止天数（从执行日起算）"
    end
    attribute :activity_note, :string do
      public? true
      description "活动备注"
    end
    attribute :trigger_type, :atom do
      constraints one_of: [:manual, :on_upload, :on_update, :scheduled]
      default :manual
      public? true
      description "manual=手动, on_upload=上传自动, on_update=更新自动, scheduled=定时"
    end
    attribute :sequence, :integer do
      public? true
      description "显示排序"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :folder, UniboExPoc.Documents.Document do
      public? true
      allow_nil? false
    end
    many_to_many :required_tags, UniboExPoc.Documents.Tag do
      public? true
      through UniboExPoc.Documents.WorkflowRuleRequiredTagLink
    end
    many_to_many :excluded_tags, UniboExPoc.Documents.Tag do
      public? true
      through UniboExPoc.Documents.WorkflowRuleExcludedTagLink
    end
    many_to_many :tag_actions, UniboExPoc.Documents.Tag do
      public? true
      through UniboExPoc.Documents.WorkflowRuleTagActionLink
    end
    many_to_many :remove_tags, UniboExPoc.Documents.Tag do
      public? true
      through UniboExPoc.Documents.WorkflowRuleRemoveTagLink
    end
    belongs_to :partner, UniboExPoc.Documents.Contact do
      public? true
    end
    belongs_to :owner, UniboExPoc.Documents.Party do
      public? true
      source_attribute :owner_party_id
    end
    belongs_to :folder_action, UniboExPoc.Documents.Document do
      public? true
    end
    belongs_to :partner_action, UniboExPoc.Documents.Contact do
      public? true
    end
    belongs_to :owner_action, UniboExPoc.Documents.Party do
      public? true
      source_attribute :owner_action_party_id
    end
    belongs_to :activity_type, UniboExPoc.Documents.ActivityType do
      public? true
    end
    belongs_to :activity_user, UniboExPoc.Documents.Party do
      public? true
      source_attribute :activity_user_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :note, :folder_id, :condition_type, :domain, :partner_id, :folder_action_id, :partner_action_id, :create_model, :activity_option, :activity_type_id, :activity_summary, :activity_date_deadline_range, :activity_note, :trigger_type, :sequence]
      argument :owner_id, :uuid
      argument :owner_action_id, :uuid
      argument :activity_user_id, :uuid
      argument :folder_id, :uuid, allow_nil?: false
      change manage_relationship(:folder_id, :folder, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:folder_id)
      validate present(:condition_type)
      validate present(:activity_type_id)
      # message: "当 activity_option=schedule 时必须指定活动类型"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :note, :condition_type, :domain, :partner_id, :folder_action_id, :partner_action_id, :create_model, :activity_option, :activity_type_id, :activity_summary, :activity_date_deadline_range, :activity_note, :trigger_type, :sequence]
      argument :owner_id, :uuid
      argument :owner_action_id, :uuid
      argument :activity_user_id, :uuid
      # skipped: validate present :activity_type_id (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :execute do
      description "对一组文档执行此工作流规则"
      argument :document_ids, {:array, :string}, allow_nil?: false
      # skipped: validate present :activity_type_id (incompatible with bulk update atomic path)
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
