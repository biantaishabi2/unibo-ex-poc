defmodule UniboV4.Ofbiz.Order.OrderItemShipGroupAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_item_ship_group_assocs"
    repo UniboV4.Repo
  end

  graphql do
    type :order_order_item_ship_group_assoc

    queries do
      get :get_order_order_item_ship_group_assoc, :read
      list :list_order_order_item_ship_group_assocs, :read
    end

    mutations do
      create :create_order_order_item_ship_group_assoc, :create
      update :update_order_order_item_ship_group_assoc, :update
      destroy :delete_order_order_item_ship_group_assoc, :destroy
    end

  end

  attributes do
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
    attribute :quantity, :decimal, public?: true
    attribute :cancel_quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboV4.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
