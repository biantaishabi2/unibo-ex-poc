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
defmodule UniboV4.Events.Events.EventTicket do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Events.Events,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :description, :string, public?: true
    attribute :price, :decimal do
      allow_nil? false
      default 0
      public? true
    end
    attribute :currency_id, :string do
      default "CNY"
      public? true
    end
    attribute :quantity, :integer, public?: true
    attribute :sold_count, :integer do
      default 0
      public? true
    end
    attribute :sales_start, :utc_datetime, public?: true
    attribute :sales_end, :utc_datetime, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :max_per_order, :integer do
      default 10
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Events.Events.Event do
      public? true
      allow_nil? false
    end
    has_many :registrations, UniboV4.Events.Events.EventRegistration do
      public? true
      destination_attribute :ticket_id
    end
    has_many :translations, UniboV4.Events.Events.EventTicketTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :price, :currency_id, :quantity, :sales_start, :sales_end, :max_per_order]
      argument :event_id, :uuid, allow_nil?: false
      change manage_relationship(:event_id, :event, type: :append, on_lookup: :relate)
      validate present(:event_id)
      validate present(:name)
      validate present(:price)
      # TODO: compare :price 参数无法识别
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
      accept [:name, :description, :price, :quantity, :sales_start, :sales_end, :is_active, :max_per_order]
      # skipped: validate compare :price (incompatible with bulk update atomic path)
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
    update :close_sales do
      accept []
      # skipped: validate compare :price (incompatible with bulk update atomic path)
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

end
