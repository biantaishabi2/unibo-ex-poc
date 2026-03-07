defmodule UniboExPoc.Ofbiz.Order.OrderItemAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_item_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item_attribute

    queries do
      get :get_order_order_item_attribute, :read
      list :list_order_order_item_attributes, :read
    end

    mutations do
      create :create_order_order_item_attribute, :create
      update :update_order_order_item_attribute, :update
      destroy :delete_order_order_item_attribute, :destroy
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
