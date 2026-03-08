defmodule UniboV4.Ofbiz.Accounting.InvoiceContactMech do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_contact_meches"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_invoice_contact_mech

    queries do
      get :get_accounting_invoice_contact_mech, :read
      list :list_accounting_invoice_contact_mechs, :read
    end

    mutations do
      create :create_accounting_invoice_contact_mech, :create
      update :update_accounting_invoice_contact_mech, :update
      destroy :delete_accounting_invoice_contact_mech, :destroy
    end

  end

  attributes do
    attribute :contact_mech_purpose_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :contact_mech_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :invoice, UniboV4.Ofbiz.Accounting.Invoice do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
