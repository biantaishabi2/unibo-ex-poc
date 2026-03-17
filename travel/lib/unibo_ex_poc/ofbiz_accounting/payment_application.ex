defmodule UniboExPoc.Ofbiz.Accounting.PaymentApplication do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_applications"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_payment_application

    queries do
      get :get_ofbiz_accounting_payment_application, :read
      list :list_ofbiz_accounting_payment_applications, :read
    end

    mutations do
      create :create_ofbiz_accounting_payment_application, :create
      update :update_ofbiz_accounting_payment_application, :update
      destroy :delete_ofbiz_accounting_payment_application, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_application_id, :string, public?: true
    attribute :invoice_item_seq_id, :string, public?: true
    attribute :tax_auth_geo_id, :string, public?: true
    attribute :amount_applied, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
      public? true
    end
    belongs_to :invoice, UniboExPoc.Ofbiz.Accounting.Invoice do
      public? true
    end
    belongs_to :billing_account, UniboExPoc.Ofbiz.Accounting.BillingAccount do
      public? true
    end
    belongs_to :to_payment, UniboExPoc.Ofbiz.Accounting.Payment do
      public? true
    end
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
      source_attribute :override_gl_account_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
