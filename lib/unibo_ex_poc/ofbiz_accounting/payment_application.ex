defmodule UniboV4.Ofbiz.Accounting.PaymentApplication do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_applications"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_payment_application

    queries do
      get :get_accounting_payment_application, :read
      list :list_accounting_payment_applications, :read
    end

    mutations do
      create :create_accounting_payment_application, :create
      update :update_accounting_payment_application, :update
      destroy :delete_accounting_payment_application, :destroy
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
    belongs_to :payment, UniboV4.Ofbiz.Accounting.Payment do
      public? true
    end
    belongs_to :invoice, UniboV4.Ofbiz.Accounting.Invoice do
      public? true
    end
    belongs_to :billing_account, UniboV4.Ofbiz.Accounting.BillingAccount do
      public? true
    end
    belongs_to :to_payment, UniboV4.Ofbiz.Accounting.Payment do
      public? true
    end
    belongs_to :gl_account, UniboV4.Ofbiz.Accounting.GlAccount do
      public? true
      source_attribute :override_gl_account_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
