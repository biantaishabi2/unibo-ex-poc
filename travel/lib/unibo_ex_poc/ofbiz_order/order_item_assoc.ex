defmodule UniboExPoc.Ofbiz.Order.OrderItemAssoc do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_item_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item_assoc

    queries do
      get :get_order_order_item_assoc, :read
      list :list_order_order_item_assocs, :read
    end

    mutations do
      create :create_order_order_item_assoc, :create
      update :update_order_order_item_assoc, :update
      destroy :delete_order_order_item_assoc, :destroy
    end

  end

  attributes do
    attribute :order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :ship_group_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :to_order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :to_order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :to_ship_group_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_item_assoc_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_item_assoc_type, UniboExPoc.Ofbiz.Order.OrderItemAssocType do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :from_order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      define_attribute? false
      attribute_type :string
    end
    belongs_to :to_order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :to_order_id
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
