defmodule UniboExPoc.Ofbiz.Accounting.BillingAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "账单科目付款方式"
  end

  postgres do
    table "accounting_billing_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_billing_account

    queries do
      get :get_ofbiz_accounting_billing_account, :read
      list :list_ofbiz_accounting_billing_accounts, :read
    end

    mutations do
      create :create_ofbiz_accounting_billing_account, :create
      update :update_ofbiz_accounting_billing_account, :update
      destroy :delete_ofbiz_accounting_billing_account, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :billing_account_id, :string, public?: true
    attribute :account_limit, :decimal, public?: true
    attribute :account_currency_uom_id, :string, public?: true
    attribute :contact_mech_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :description, :string, public?: true
    attribute :external_account_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
