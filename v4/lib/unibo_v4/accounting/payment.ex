defmodule UniboV4.Accounting.Payment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Accounting.Payment.Notifier]

  postgres do
    table "payments"
    repo UniboV4.Repo
  end

  graphql do
    type :payment

    queries do
      get :get_payment, :read
      list :list_payments, :read
    end

    mutations do
      create :create_payment, :create
      update :confirm_payment, :confirm
      update :cancel_payment, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_number, :string, allow_nil?: false
    attribute :payment_type, :atom do
      allow_nil? false
      constraints one_of: [:customer_payment, :vendor_payment, :refund]
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :sent, :received, :cancelled]
      default :draft
    end
    attribute :amount, :decimal, allow_nil?: false
    attribute :currency, :string, default: "CNY"
    attribute :payment_date, :date, allow_nil?: false
    attribute :payment_method, :atom, constraints: [one_of: [:bank_transfer, :cash, :check, :credit_card, :other]]
    attribute :reference_number, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :applications, UniboV4.Accounting.PaymentApplication
    belongs_to :created_by, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:payment_number, :payment_type, :amount, :currency, :payment_date, :payment_method, :reference_number, :notes]
      validate present(:payment_number)
      change relate_actor(:created_by)
    end
    update :confirm do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以确认"
      end
      change set_attribute(:status, :confirmed)
    end
    update :cancel do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

  identities do
    identity :unique_payment_number, [:payment_number]
  end

end
