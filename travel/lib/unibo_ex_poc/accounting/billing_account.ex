# Workflow: billing_account_lifecycle — 账户余额管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Accounting.BillingAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "客户/供应商账户余额"
  end

  postgres do
    table "accounting_billing_accounts"
    repo UniboExPoc.Repo
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
      description "账户编号"
    end
    attribute :account_type, :atom do
      allow_nil? false
      constraints one_of: [:receivable, :payable]
      public? true
      description "应收/应付"
    end
    attribute :balance, :decimal do
      default 0
      public? true
      description "当前余额"
    end
    attribute :credit_limit, :decimal do
      public? true
      description "信用额度"
    end
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
