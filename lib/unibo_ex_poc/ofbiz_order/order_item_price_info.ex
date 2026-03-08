defmodule UniboV4.Ofbiz.Order.OrderItemPriceInfo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_item_price_infos"
    repo UniboV4.Repo
  end

  graphql do
    type :order_order_item_price_info

    queries do
      get :get_order_order_item_price_info, :read
      list :list_order_order_item_price_infos, :read
    end

    mutations do
      create :create_order_order_item_price_info, :create
      update :update_order_order_item_price_info, :update
      destroy :delete_order_order_item_price_info, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_item_price_info_id, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :product_price_rule_id, :string, public?: true
    attribute :product_price_action_seq_id, :string, public?: true
    attribute :modify_amount, :decimal, public?: true
    attribute :description, :string, public?: true
    attribute :rate_code, :string, public?: true
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
