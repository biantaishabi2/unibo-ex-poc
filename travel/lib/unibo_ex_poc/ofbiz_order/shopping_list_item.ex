defmodule UniboExPoc.Ofbiz.Order.ShoppingListItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_shopping_list_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_shopping_list_item

    queries do
      get :get_order_shopping_list_item, :read
      list :list_order_shopping_list_items, :read
    end

    mutations do
      create :create_order_shopping_list_item, :create
      update :update_order_shopping_list_item, :update
      destroy :delete_order_shopping_list_item, :destroy
    end

  end

  attributes do
    attribute :shopping_list_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shopping_list_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :modified_price, :decimal, public?: true
    attribute :reserv_start, :utc_datetime, public?: true
    attribute :reserv_length, :decimal, public?: true
    attribute :reserv_persons, :decimal, public?: true
    attribute :quantity_purchased, :decimal, public?: true
    attribute :config_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shopping_list, UniboExPoc.Ofbiz.Order.ShoppingList do
      public? true
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
