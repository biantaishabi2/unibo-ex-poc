defmodule UniboExPoc.Ofbiz.Order.OrderItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_item

    queries do
      get :get_order_order_item, :read
      list :list_order_order_items, :read
    end

    mutations do
      create :create_order_order_item, :create
      update :update_order_order_item, :update
      destroy :delete_order_order_item, :destroy
    end

  end

  attributes do
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :external_id, :string, public?: true
    attribute :order_item_group_seq_id, :string, public?: true
    attribute :is_item_group_primary, :boolean, public?: true
    attribute :from_inventory_item_id, :string, public?: true
    attribute :budget_id, :string, public?: true
    attribute :budget_item_seq_id, :string, public?: true
    attribute :product_id, :string, public?: true
    attribute :supplier_product_id, :string, public?: true
    attribute :product_feature_id, :string, public?: true
    attribute :prod_catalog_id, :string, public?: true
    attribute :product_category_id, :string, public?: true
    attribute :is_promo, :boolean, public?: true
    attribute :quote_id, :string, public?: true
    attribute :quote_item_seq_id, :string, public?: true
    attribute :shopping_list_id, :string, public?: true
    attribute :shopping_list_item_seq_id, :string, public?: true
    attribute :subscription_id, :string, public?: true
    attribute :deployment_id, :string, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :cancel_quantity, :decimal, public?: true
    attribute :selected_amount, :decimal, public?: true
    attribute :unit_price, :decimal, public?: true
    attribute :unit_list_price, :decimal, public?: true
    attribute :unit_average_cost, :decimal, public?: true
    attribute :unit_recurring_price, :decimal, public?: true
    attribute :discount_rate, :decimal, public?: true
    attribute :is_modified_price, :boolean, public?: true
    attribute :recurring_freq_uom_id, :string, public?: true
    attribute :item_description, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :corresponding_po_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :sync_status_id, :string, public?: true
    attribute :estimated_ship_date, :utc_datetime, public?: true
    attribute :estimated_delivery_date, :utc_datetime, public?: true
    attribute :auto_cancel_date, :utc_datetime, public?: true
    attribute :dont_cancel_set_date, :utc_datetime, public?: true
    attribute :dont_cancel_set_user_login, :string, public?: true
    attribute :ship_before_date, :utc_datetime, public?: true
    attribute :ship_after_date, :utc_datetime, public?: true
    attribute :reserve_after_date, :utc_datetime, public?: true
    attribute :cancel_back_order_date, :utc_datetime do
      public? true
      description "用于在过期时取消所有供应商订单"
    end
    attribute :override_gl_account_id, :string do
      public? true
      description "用于指定用于调整的覆盖或实际glAccountId，避免初始过账后配置更改引发的问题等"
    end
    attribute :sales_opportunity_id, :string, public?: true
    attribute :change_by_user_login_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
    belongs_to :order_item_type, UniboExPoc.Ofbiz.Order.OrderItemType do
      public? true
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
