defmodule UniboExPoc.Ofbiz.Accounting.Invoice do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoices"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_invoice

    queries do
      get :get_ofbiz_accounting_invoice, :read
      list :list_ofbiz_accounting_invoices, :read
    end

    mutations do
      create :create_ofbiz_accounting_invoice, :create
      update :update_ofbiz_accounting_invoice, :update
      destroy :delete_ofbiz_accounting_invoice, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_id, :string, public?: true
    attribute :party_id_from, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :contact_mech_id, :string, public?: true
    attribute :invoice_date, :utc_datetime, public?: true
    attribute :due_date, :utc_datetime, public?: true
    attribute :paid_date, :utc_datetime, public?: true
    attribute :invoice_message, :string, public?: true
    attribute :reference_number, :string, public?: true
    attribute :description, :string, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :recurrence_info_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :invoice_type, UniboExPoc.Ofbiz.Accounting.InvoiceType do
      public? true
    end
    belongs_to :billing_account, UniboExPoc.Ofbiz.Accounting.BillingAccount do
      public? true
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
