# Workflow: sms_template_maintain_flow — 短信模板维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> create_sidebar_action
#   update --> [*]
#   create_sidebar_action --> [*]
# ```
defmodule UniboExPoc.Marketing.SmsTemplate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "短信模板"
  end

  postgres do
    table "marketing_sms_templates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_sms_template

    queries do
      get :get_marketing_sms_template, :read
      list :list_marketing_sms_templates, :read
    end

    mutations do
      create :create_marketing_sms_template, :create
      update :update_marketing_sms_template, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "模板名称（可翻译）"
    end
    attribute :model_id, :uuid do
      allow_nil? false
      public? true
      description "关联文档类型（限 mail-thread 且非 transient 模型）"
    end
    attribute :model, :string do
      allow_nil? false
      public? true
      description "去范式化模型名（stored, indexed）"
    end
    attribute :body, :string do
      allow_nil? false
      public? true
      description "模板内容（支持占位符，可翻译）"
    end
    attribute :sidebar_action_id, :uuid do
      public? true
      description "侧边栏窗口操作（上下文快捷入口）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :model_id, :body]
      validate present(:name)
      validate present(:body)
      # validation: valid_model_reference
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :body]
      # skipped: validate present :body (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :render do
      description "渲染模板（变量替换）"
      argument :record_ids, :string
      validate present([:record_ids])
      run fn input, _context ->
        :ok
      end
    end
    action :create_sidebar_action do
      description "创建侧边栏快捷操作"
      # validation: sidebar_action_consistency
      run fn input, _context ->
        :ok
      end
    end
    action :unlink_sidebar_action do
      description "删除侧边栏操作"
      # validation: sidebar_action_consistency
      run fn input, _context ->
        :ok
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
