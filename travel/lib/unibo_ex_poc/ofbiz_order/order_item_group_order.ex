defmodule UniboExPoc.Ofbiz.Order.OrderItemGroupOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_item_group_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item_group_order

    queries do
      get :get_order_order_item_group_order, :read
      list :list_order_order_item_group_orders, :read
    end

    mutations do
      create :create_order_order_item_group_order, :create
      update :update_order_order_item_group_order, :update
      destroy :delete_order_order_item_group_order, :destroy
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
    attribute :group_order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
