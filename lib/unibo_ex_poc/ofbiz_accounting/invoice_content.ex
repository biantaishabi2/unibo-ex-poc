defmodule UniboExPoc.Ofbiz.Accounting.InvoiceContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_invoice_content

    queries do
      get :get_accounting_invoice_content, :read
      list :list_accounting_invoice_contents, :read
    end

    mutations do
      create :create_accounting_invoice_content, :create
      update :update_accounting_invoice_content, :update
      destroy :delete_accounting_invoice_content, :destroy
    end

  end

  attributes do
    attribute :content_id, :string do
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :invoice, UniboExPoc.Ofbiz.Accounting.Invoice do
      public? true
    end
    belongs_to :invoice_content_type, UniboExPoc.Ofbiz.Accounting.InvoiceContentType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
