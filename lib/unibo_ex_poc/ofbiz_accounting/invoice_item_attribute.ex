defmodule UniboV4.Ofbiz.Accounting.InvoiceItemAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_item_attributes"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_invoice_item_attribute

    queries do
      get :get_accounting_invoice_item_attribute, :read
      list :list_accounting_invoice_item_attributes, :read
    end

    mutations do
      create :create_accounting_invoice_item_attribute, :create
      update :update_accounting_invoice_item_attribute, :update
      destroy :delete_accounting_invoice_item_attribute, :destroy
    end

  end

  attributes do
    attribute :invoice_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :invoice_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
