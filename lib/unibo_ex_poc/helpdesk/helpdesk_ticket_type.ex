# Workflow: ticket_type_management — 工单类型管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Helpdesk.HelpdeskTicketType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "工单类型/分类，用于 SLA 策略匹配条件之一"
  end

  postgres do
    table "helpdesk_ticket_types"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_helpdesk_ticket_type

    queries do
      get :get_helpdesk_helpdesk_ticket_type, :read
      list :list_helpdesk_helpdesk_ticket_types, :read
    end

    mutations do
      create :create_helpdesk_helpdesk_ticket_type, :create
      update :update_helpdesk_helpdesk_ticket_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "类型名称（如\"技术问题\"、\"退货\"）"
    end
    attribute :description, :string do
      public? true
      description "类型描述"
    end
    attribute :sequence, :integer do
      allow_nil? false
      default 10
      public? true
      description "排序权重，用于选择列表排序"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "归档标记"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :tickets, UniboV4.Helpdesk.HelpdeskTicket do
      public? true
      destination_attribute :ticket_type_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :sequence]
      validate present(:name)
      # message: "类型名称必填"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :sequence, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_ticket_type_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
