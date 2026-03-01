# Workflow: billing_account_lifecycle — 账户余额管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Accounting.BillingAccount do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "accounting_billing_accounts"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_billing_account

    queries do
      get :get_accounting_billing_account, :read
      list :list_accounting_billing_accounts, :read
    end

    mutations do
      create :create_accounting_billing_account, :create
      update :update_accounting_billing_account, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :account_number, :string do
      allow_nil? false
      public? true
    end
    attribute :account_type, :atom do
      allow_nil? false
      constraints one_of: [:receivable, :payable]
      public? true
    end
    attribute :balance, :decimal do
      default 0
      public? true
    end
    attribute :credit_limit, :decimal, public?: true
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :from_date, :date, public?: true
    attribute :thru_date, :date, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:account_number, :account_type, :credit_limit, :currency, :from_date, :thru_date, :description]
      validate present(:account_number)
      validate compare(:credit_limit, greater_than_or_equal_to: 0)
      # message: "信用额度不能为负"
    end
    update :update do
      primary? true
      accept [:credit_limit, :thru_date, :description]
      # skipped: validate compare :credit_limit (incompatible with bulk update atomic path)
      require_atomic? false
    end
  end

  identities do
    identity :unique_account_number, [:account_number]
  end

end
