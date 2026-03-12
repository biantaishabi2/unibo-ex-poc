defmodule UniboExPoc.Ofbiz.Accounting.InvoiceItemType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_item_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_invoice_item_type

    queries do
      get :get_ofbiz_accounting_invoice_item_type, :read
      list :list_ofbiz_accounting_invoice_item_types, :read
    end

    mutations do
      create :create_ofbiz_accounting_invoice_item_type, :create
      update :update_ofbiz_accounting_invoice_item_type, :update
      destroy :delete_ofbiz_accounting_invoice_item_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_item_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_invoice_item_type, UniboExPoc.Ofbiz.Accounting.InvoiceItemType do
      public? true
      source_attribute :parent_type_id
    end
    belongs_to :default_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
