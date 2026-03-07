defmodule UniboExPoc.Ofbiz.Order.OrderItemChange do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_item_changes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item_change

    queries do
      get :get_order_order_item_change, :read
      list :list_order_order_item_changes, :read
    end

    mutations do
      create :create_order_order_item_change, :create
      update :update_order_order_item_change, :update
      destroy :delete_order_order_item_change, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_item_change_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :change_type_enum_id, :string, public?: true
    attribute :change_datetime, :utc_datetime, public?: true
    attribute :change_user_login, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :cancel_quantity, :decimal, public?: true
    attribute :unit_price, :decimal, public?: true
    attribute :item_description, :string, public?: true
    attribute :reason_enum_id, :string, public?: true
    attribute :change_comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
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
