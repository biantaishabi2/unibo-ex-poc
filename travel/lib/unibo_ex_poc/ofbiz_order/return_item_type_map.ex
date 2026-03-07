defmodule UniboExPoc.Ofbiz.Order.ReturnItemTypeMap do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "订单商品或orderAdjustmentTypeId和returnAdjustmentTypeId的映射。针对不同类型的退货（客户 vs. 供应商）的分别映射"
  end

  postgres do
    table "order_return_item_type_maps"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_return_item_type_map

    queries do
      get :get_order_return_item_type_map, :read
      list :list_order_return_item_type_maps, :read
    end

    mutations do
      create :create_order_return_item_type_map, :create
      update :update_order_return_item_type_map, :update
      destroy :delete_order_return_item_type_map, :destroy
    end

  end

  attributes do
    attribute :return_item_map_key, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :return_item_type, UniboExPoc.Ofbiz.Order.ReturnItemType do
      public? true
      attribute_type :string
    end
    belongs_to :return_header_type, UniboExPoc.Ofbiz.Order.ReturnHeaderType do
      public? true
      attribute_type :string
    end
    belongs_to :return_adjustment_type, UniboExPoc.Ofbiz.Order.ReturnAdjustmentType do
      public? true
      source_attribute :return_item_type_id
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
