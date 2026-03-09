# Workflow: worksheet_lifecycle — 工作表生命周期（创建→填写→签名）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> sign_worksheet
#   update --> update
#   update --> sign_worksheet
#   sign_worksheet --> [*]
# ```
defmodule UniboExPoc.Helpdesk.Worksheet do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工作表实例，技术员现场填写的结构化表单数据"
  end

  postgres do
    table "helpdesk_worksheets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_worksheet

    queries do
      get :get_helpdesk_worksheet, :read
      list :list_helpdesk_worksheets, :read
    end

    mutations do
      create :create_helpdesk_worksheet, :create
      update :update_helpdesk_worksheet, :update
      update :sign_worksheet_helpdesk_worksheet, :sign_worksheet
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :notes, :string do
      public? true
      description "技术员备注"
    end
    attribute :signature, :string do
      public? true
      description "客户签名数据（Base64 编码）"
    end
    attribute :signed_at, :utc_datetime do
      public? true
      description "签名时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :service_order, UniboExPoc.Helpdesk.FieldServiceOrder do
      public? true
      allow_nil? false
    end
    belongs_to :template, UniboExPoc.Helpdesk.WorksheetTemplate do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:notes]
      argument :service_order_id, :uuid, allow_nil?: false
      argument :template_id, :uuid, allow_nil?: false
      change manage_relationship(:service_order_id, :service_order, type: :append, on_lookup: :relate)
      change manage_relationship(:template_id, :template, type: :append, on_lookup: :relate)
      validate present(:service_order)
      # message: "必须关联现场服务任务"
      validate present(:template)
      # message: "必须指定工作表模板"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:notes]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :sign_worksheet do
      description "客户签名确认工作表"
      accept [:signature]
      # skipped: validate present :signature (incompatible with bulk update atomic path)
      change set_attribute(:signed_at, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
