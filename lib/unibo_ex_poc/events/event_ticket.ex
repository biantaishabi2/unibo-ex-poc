# Workflow: ticket_lifecycle — 票种管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> close_sales
#   create --> destroy
#   update --> update
#   update --> close_sales
#   close_sales --> [*]
# ```
defmodule UniboV4.Events.EventTicket do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "活动票种，定义不同价格/权益的参与方式"
  end

  postgres do
    table "events_event_tickets"
    repo UniboV4.Repo
  end

  graphql do
    type :events_event_ticket

    queries do
      get :get_events_event_ticket, :read
      list :list_events_event_tickets, :read
    end

    mutations do
      create :create_events_event_ticket, :create
      update :update_events_event_ticket, :update
      update :close_sales_events_event_ticket, :close_sales
      destroy :delete_events_event_ticket, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "票种名称（如 VIP/普通/免费）"
    end
    attribute :description, :string do
      public? true
      description "票种描述/权益说明"
    end
    attribute :price, :decimal do
      allow_nil? false
      default 0
      public? true
      description "票价"
    end
    attribute :currency_id, :string do
      default "CNY"
      public? true
      description "币种"
    end
    attribute :quantity, :integer do
      public? true
      description "总库存数量，null 表示不限"
    end
    attribute :sold_count, :integer do
      default 0
      public? true
      description "已售数量"
    end
    attribute :sales_start, :utc_datetime do
      public? true
      description "开售时间"
    end
    attribute :sales_end, :utc_datetime do
      public? true
      description "停售时间"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否在售"
    end
    attribute :max_per_order, :integer do
      default 10
      public? true
      description "单次最大购买数量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :event, UniboV4.Events.Event do
      public? true
      allow_nil? false
    end
    has_many :registrations, UniboV4.Events.EventRegistration do
      public? true
      source_attribute :event_id
      destination_attribute :ticket_id
    end
    has_many :translations, UniboV4.Events.EventTicketTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:event_id, :name, :description, :price, :currency_id, :quantity, :sales_start, :sales_end, :max_per_order]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:name)
      validate present(:price)
      # WARNING: compare :price 参数无法识别，请检查 YAML 定义
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :price, :quantity, :sales_start, :sales_end, :is_active, :max_per_order]
      # skipped: validate compare :price (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :close_sales do
      description "关闭售票"
      accept []
      # skipped: validate compare :price (incompatible with bulk update atomic path)
      change set_attribute(:is_active, false)
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
    archive_related [:registrations]
  end

end
