defmodule UniboV4.Helpdesk.Appointment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "appointments"
    repo UniboV4.Repo
  end

  graphql do
    type :appointment

    queries do
      get :get_appointment, :read
      list :list_appointments, :read
    end

    mutations do
      create :create_appointment, :create
      update :confirm_appointment, :confirm
      update :complete_appointment, :complete
      update :cancel_appointment, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:scheduled, :confirmed, :completed, :cancelled, :no_show]
      default :scheduled
    end
    attribute :start_time, :utc_datetime, allow_nil?: false
    attribute :end_time, :utc_datetime, allow_nil?: false
    attribute :location, :string
    attribute :description, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:title, :start_time, :end_time, :location, :description, :notes]
      validate present(:title)
      change relate_actor(:created_by)
    end
    update :confirm do
      accept []
      validate attribute_equals(:status, :scheduled) do
        message "只有已排期状态可以确认"
      end
      change set_attribute(:status, :confirmed)
    end
    update :complete do
      accept []
      validate attribute_equals(:status, :confirmed) do
        message "只有已确认状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
    update :cancel do
      accept []
      validate attribute_in(:status, [:scheduled, :confirmed]) do
        message "只有排期或已确认状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

end
