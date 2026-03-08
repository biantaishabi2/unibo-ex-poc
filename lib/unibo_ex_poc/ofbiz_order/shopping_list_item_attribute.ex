defmodule UniboV4.Ofbiz.Order.ShoppingListItemAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_shopping_list_item_attributes"
    repo UniboV4.Repo
  end

  graphql do
    type :order_shopping_list_item_attribute

    queries do
      get :get_order_shopping_list_item_attribute, :read
      list :list_order_shopping_list_item_attributes, :read
    end

    mutations do
      create :create_order_shopping_list_item_attribute, :create
      update :update_order_shopping_list_item_attribute, :update
      destroy :delete_order_shopping_list_item_attribute, :destroy
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
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
