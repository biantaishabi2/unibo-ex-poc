defmodule UniboExPoc.Ofbiz.Order.ReturnItemBilling do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_return_item_billings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_return_item_billing

    queries do
      get :get_order_return_item_billing, :read
      list :list_order_return_item_billings, :read
    end

    mutations do
      create :create_order_return_item_billing, :create
      update :update_order_return_item_billing, :update
      destroy :delete_order_return_item_billing, :destroy
    end

  end

  attributes do
    attribute :return_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :return_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
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
    attribute :shipment_receipt_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :return_header, UniboExPoc.Ofbiz.Order.ReturnHeader do
      public? true
      source_attribute :return_id
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
