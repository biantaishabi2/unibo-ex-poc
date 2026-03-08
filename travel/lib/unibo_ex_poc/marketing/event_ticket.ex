# Workflow: event_ticket_maintain_flow — 活动票种维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Marketing.EventTicket do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "活动票种（免费/付费），席位独立管理"
  end

  postgres do
    table "marketing_event_tickets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_event_ticket

    queries do
      get :get_marketing_event_ticket, :read
      list :list_marketing_event_tickets, :read
    end

    mutations do
      create :create_marketing_event_ticket, :create
      update :update_marketing_event_ticket, :update
      destroy :delete_marketing_event_ticket, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "票种名称"
    end
    attribute :seats_max, :integer do
      default 0
      public? true
      description "最大席位（0=不限）"
    end
    attribute :seats_limited, :boolean do
      default false
      public? true
    end
    attribute :price, :decimal do
      default 0
      public? true
      description "票价"
    end
    attribute :start_sale_date, :utc_datetime do
      public? true
      description "开售时间"
    end
    attribute :end_sale_date, :utc_datetime do
      public? true
      description "停售时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :event, UniboExPoc.Marketing.Event do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :seats_max, :seats_limited, :price, :start_sale_date, :end_sale_date]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :seats_max, :seats_limited, :price, :start_sale_date, :end_sale_date]
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
