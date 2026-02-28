defmodule UniboV4.Helpdesk.Ticket do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Helpdesk.Ticket.Notifier]

  postgres do
    table "tickets"
    repo UniboV4.Repo
  end

  graphql do
    type :ticket

    queries do
      get :get_ticket, :read
      list :list_tickets, :read
    end

    mutations do
      create :create_ticket, :create
      update :assign_ticket, :assign
      update :resolve_ticket, :resolve
      update :close_ticket, :close
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :ticket_number, :string, allow_nil?: false
    attribute :subject, :string, allow_nil?: false
    attribute :description, :string
    attribute :status, :atom do
      constraints one_of: [:new, :open, :in_progress, :resolved, :closed, :cancelled]
      default :new
    end
    attribute :priority, :atom do
      constraints one_of: [:low, :medium, :high, :urgent]
      default :medium
    end
    attribute :channel, :atom do
      constraints one_of: [:email, :phone, :web, :chat, :other]
      default :web
    end
    attribute :resolution, :string
    attribute :resolved_date, :utc_datetime
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :category, UniboV4.Helpdesk.TicketCategory
    belongs_to :assigned_to, UniboV4.Accounts.User
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:ticket_number, :subject, :description, :priority, :channel]
      argument :category_id, :uuid
      validate present(:ticket_number)
      validate present(:subject)
      change relate_actor(:created_by)
    end
    update :assign do
      accept []
      argument :assigned_to_id, :uuid, allow_nil?: false
      change set_attribute(:status, :open)
    end
    update :resolve do
      accept [:resolution]
      validate attribute_in(:status, [:new, :open, :in_progress]) do
        message "只有活跃工单可以解决"
      end
      change set_attribute(:status, :resolved)
    end
    update :close do
      accept []
      validate attribute_equals(:status, :resolved) do
        message "只有已解决工单可以关闭"
      end
      change set_attribute(:status, :closed)
    end
  end

  identities do
    identity :unique_ticket_number, [:ticket_number]
  end

end
