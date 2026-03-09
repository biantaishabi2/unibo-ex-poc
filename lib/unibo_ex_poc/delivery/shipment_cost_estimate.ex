# Workflow: cost_estimate_maintain_flow — 运费估算规则维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentCostEstimate do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "运费估算规则，按承运商/方式/区域/重量/数量/价格阶梯灵活配置"
  end

  postgres do
    table "delivery_shipment_cost_estimates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_shipment_cost_estimate

    queries do
      get :get_delivery_shipment_cost_estimate, :read
      list :list_delivery_shipment_cost_estimates, :read
    end

    mutations do
      create :create_delivery_shipment_cost_estimate, :create
      update :update_delivery_shipment_cost_estimate, :update
      destroy :delete_delivery_shipment_cost_estimate, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_cost_estimate_id, :string do
      public? true
      description "OFBiz 原始 ID"
    end
    attribute :carrier_role_type_id, :string do
      public? true
      description "承运商角色类型"
    end
    attribute :product_store_id, :string do
      public? true
      description "适用门店/渠道"
    end
    attribute :role_type_id, :string do
      public? true
      description "客户角色类型"
    end
    attribute :geo_id_to, :string do
      public? true
      description "目的地区域 ID"
    end
    attribute :geo_id_from, :string do
      public? true
      description "出发地区域 ID"
    end
    attribute :weight_break_id, :string do
      public? true
      description "重量阶梯 ID"
    end
    attribute :weight_uom_id, :string do
      public? true
      description "重量单位"
    end
    attribute :weight_unit_price, :decimal do
      public? true
      description "单位重量运费"
    end
    attribute :quantity_break_id, :string do
      public? true
      description "数量阶梯 ID"
    end
    attribute :quantity_uom_id, :string do
      public? true
      description "数量单位"
    end
    attribute :quantity_unit_price, :decimal do
      public? true
      description "单位数量运费"
    end
    attribute :price_break_id, :string do
      public? true
      description "价格阶梯 ID"
    end
    attribute :price_uom_id, :string do
      public? true
      description "价格单位"
    end
    attribute :price_unit_price, :decimal do
      public? true
      description "单位货值运费"
    end
    attribute :order_flat_price, :decimal do
      public? true
      description "订单固定运费"
    end
    attribute :order_price_percent, :decimal do
      public? true
      description "按订单金额比例收费（%）"
    end
    attribute :order_item_flat_price, :decimal do
      public? true
      description "每条目固定运费"
    end
    attribute :shipping_price_percent, :decimal do
      public? true
      description "按运费金额再加收比例（%）"
    end
    attribute :oversize_unit, :decimal do
      public? true
      description "超尺寸单位价格"
    end
    attribute :oversize_price, :decimal do
      public? true
      description "超尺寸附加费"
    end
    attribute :feature_percent, :decimal do
      public? true
      description "特性附加比例（%）"
    end
    attribute :feature_price, :decimal do
      public? true
      description "特性固定附加费"
    end
    attribute :product_feature_group_id, :string do
      public? true
      description "适用商品特性分组"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_method_type, UniboExPoc.Delivery.ShipmentMethodType do
      public? true
    end
    belongs_to :carrier_party, UniboExPoc.Delivery.Party do
      public? true
    end
    belongs_to :party, UniboExPoc.Delivery.Party do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_cost_estimate_id, :shipment_method_type_id, :carrier_party_id, :carrier_role_type_id, :product_store_id, :geo_id_from, :geo_id_to, :weight_unit_price, :weight_uom_id, :weight_break_id, :quantity_unit_price, :quantity_uom_id, :quantity_break_id, :price_unit_price, :price_uom_id, :price_break_id, :order_flat_price, :order_price_percent, :order_item_flat_price, :shipping_price_percent, :oversize_unit, :oversize_price, :feature_percent, :feature_price, :product_feature_group_id]
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:weight_unit_price, :order_flat_price, :order_price_percent, :order_item_flat_price, :oversize_price, :shipping_price_percent]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
