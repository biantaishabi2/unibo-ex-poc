defmodule UniboV4.Ofbiz.Order.ReturnItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "order_return_items"
    repo UniboV4.Repo
  end

  graphql do
    type :order_return_item

    queries do
      get :get_order_return_item, :read
      list :list_order_return_items, :read
    end

    mutations do
      create :create_order_return_item, :create
      update :update_order_return_item, :update
      destroy :delete_order_return_item, :destroy
    end

  end

  attributes do
    attribute :return_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_id, :string do
      public? true
      description "我们需要此字段来确定产品的净销售额"
    end
    attribute :description, :string, public?: true
    attribute :order_item_seq_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :expected_item_status, :string, public?: true
    attribute :return_quantity, :decimal do
      public? true
      description "由客户承诺"
    end
    attribute :received_quantity, :decimal do
      public? true
      description "实际从客户收到"
    end
    attribute :return_price, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :return_header, UniboV4.Ofbiz.Order.ReturnHeader do
      public? true
      source_attribute :return_id
      attribute_type :string
    end
    belongs_to :return_reason, UniboV4.Ofbiz.Order.ReturnReason do
      public? true
      attribute_type :string
    end
    belongs_to :return_type, UniboV4.Ofbiz.Order.ReturnType do
      public? true
      attribute_type :string
    end
    belongs_to :return_item_type, UniboV4.Ofbiz.Order.ReturnItemType do
      public? true
      attribute_type :string
    end
    belongs_to :return_item_response, UniboV4.Ofbiz.Order.ReturnItemResponse do
      public? true
      attribute_type :string
    end
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
