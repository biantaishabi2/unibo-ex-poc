defmodule UniboExPoc.Ofbiz.Accounting.InvoiceItemAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_item_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_invoice_item_assoc

    queries do
      get :get_accounting_invoice_item_assoc, :read
      list :list_accounting_invoice_item_assocs, :read
    end

    mutations do
      create :create_accounting_invoice_item_assoc, :create
      update :update_accounting_invoice_item_assoc, :update
      destroy :delete_accounting_invoice_item_assoc, :destroy
    end

  end

  attributes do
    attribute :invoice_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :invoice_item_seq_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :invoice_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :invoice_item_seq_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :party_id_from, :string, public?: true
    attribute :party_id_to, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :invoice_item_assoc_type, UniboExPoc.Ofbiz.Accounting.InvoiceItemAssocType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
