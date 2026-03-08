defmodule UniboExPoc.Ofbiz.Order.ProductOrderItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_product_order_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_product_order_item

    queries do
      get :get_order_product_order_item, :read
      list :list_order_product_order_items, :read
    end

    mutations do
      create :create_order_product_order_item, :create
      update :update_order_product_order_item, :update
      destroy :delete_order_product_order_item, :destroy
    end

  end

  attributes do
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :engagement_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
    belongs_to :engagement_order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :engagement_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
