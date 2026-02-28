defmodule UniboV4.Accounting.BillingAccount do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "billing_accounts"
    repo UniboV4.Repo
  end

  graphql do
    type :billing_account

    queries do
      get :get_billing_account, :read
      list :list_billing_accounts, :read
    end

    mutations do
      create :create_billing_account, :create
      update :update_billing_account, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :account_number, :string, allow_nil?: false
    attribute :account_type, :atom do
      allow_nil? false
      constraints one_of: [:receivable, :payable]
    end
    attribute :balance, :decimal, default: 0
    attribute :credit_limit, :decimal
    attribute :currency, :string, default: "CNY"
    attribute :from_date, :date
    attribute :thru_date, :date
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:account_number, :account_type, :credit_limit, :currency, :from_date, :thru_date, :description]
      validate present(:account_number)
    end
    update :update do
      primary? true
      accept [:credit_limit, :thru_date, :description]
    end
  end

  validations do
    validate compare(:credit_limit, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_account_number, [:account_number]
  end

end
