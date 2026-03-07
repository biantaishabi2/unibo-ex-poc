defmodule UniboExPoc.Ofbiz.Order.OrderHeader do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_headers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_order_header

    queries do
      get :get_order_order_header, :read
      list :list_order_order_headers, :read
    end

    mutations do
      create :create_order_order_header, :create
      update :update_order_order_header, :update
      destroy :delete_order_order_header, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_id, :string, public?: true
    attribute :order_name, :string, public?: true
    attribute :external_id, :string, public?: true
    attribute :sales_channel_enum_id, :string, public?: true
    attribute :order_date, :utc_datetime, public?: true
    attribute :priority, :boolean do
      public? true
      description "设置库存预留的优先级"
    end
    attribute :entry_date, :utc_datetime, public?: true
    attribute :pick_sheet_printed_date, :utc_datetime do
      public? true
      description "当订单的拣货单被打印时，这将被设置为一个日期"
    end
    attribute :visit_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :created_by, :string, public?: true
    attribute :first_attempt_order_id, :string, public?: true
    attribute :currency_uom, :string, public?: true
    attribute :sync_status_id, :string, public?: true
    attribute :billing_account_id, :string, public?: true
    attribute :origin_facility_id, :string, public?: true
    attribute :web_site_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :agreement_id, :string, public?: true
    attribute :terminal_id, :string, public?: true
    attribute :transaction_id, :string, public?: true
    attribute :needs_inventory_issuance, :boolean, public?: true
    attribute :is_rush_order, :boolean, public?: true
    attribute :internal_code, :string, public?: true
    attribute :remaining_sub_total, :decimal, public?: true
    attribute :grand_total, :decimal, public?: true
    attribute :is_viewed, :boolean, public?: true
    attribute :invoice_per_shipment, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_type, UniboExPoc.Ofbiz.Order.OrderType do
      public? true
      attribute_type :string
    end
    belongs_to :auto_order_shopping_list, UniboExPoc.Ofbiz.Order.ShoppingList do
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
