# Workflow: event_ticket_maintain_flow — 活动票种维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Marketing.EventTicket do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "marketing_event_tickets"
    repo UniboV4.Repo
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
    end
    attribute :seats_max, :integer do
      default 0
      public? true
    end
    attribute :seats_limited, :boolean do
      default false
      public? true
    end
    attribute :price, :decimal do
      default 0
      public? true
    end
    attribute :start_sale_date, :utc_datetime, public?: true
    attribute :end_sale_date, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :event, UniboV4.Marketing.Event do
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
      accept [:name, :seats_max, :seats_limited, :price, :start_sale_date, :end_sale_date]
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
