defmodule UniboV4.Helpdesk.FieldServiceOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Helpdesk.FieldServiceOrder.Notifier]

  postgres do
    table "field_service_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :field_service_order

    queries do
      get :get_field_service_order, :read
      list :list_field_service_orders, :read
    end

    mutations do
      create :create_field_service_order, :create
      update :schedule_field_service_order, :schedule
      update :start_field_service_order, :start
      update :complete_field_service_order, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :scheduled, :in_progress, :completed, :cancelled]
      default :draft
    end
    attribute :service_type, :string
    attribute :location, :string
    attribute :scheduled_date, :utc_datetime
    attribute :completed_date, :utc_datetime
    attribute :description, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :assignments, UniboV4.Helpdesk.FieldServiceAssignment
    belongs_to :ticket, UniboV4.Helpdesk.Ticket
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :service_type, :location, :scheduled_date, :description, :notes]
      argument :ticket_id, :uuid
      validate present(:order_number)
    end
    update :schedule do
      accept [:scheduled_date]
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以安排"
      end
      change set_attribute(:status, :scheduled)
    end
    update :start do
      accept []
      validate attribute_equals(:status, :scheduled) do
        message "只有已安排状态可以开始"
      end
      change set_attribute(:status, :in_progress)
    end
    update :complete do
      accept [:notes]
      validate attribute_equals(:status, :in_progress) do
        message "只有进行中状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

end
