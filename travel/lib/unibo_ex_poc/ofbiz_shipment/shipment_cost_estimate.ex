defmodule UniboExPoc.Ofbiz.Shipment.ShipmentCostEstimate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_cost_estimates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_shipment_shipment_cost_estimate

    queries do
      get :get_ofbiz_shipment_shipment_cost_estimate, :read
      list :list_ofbiz_shipment_shipment_cost_estimates, :read
    end

    mutations do
      create :create_ofbiz_shipment_shipment_cost_estimate, :create
      update :update_ofbiz_shipment_shipment_cost_estimate, :update
      destroy :delete_ofbiz_shipment_shipment_cost_estimate, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :shipment_cost_estimate_id, :string, public?: true
    attribute :shipment_method_type_id, :string, public?: true
    attribute :carrier_party_id, :string, public?: true
    attribute :carrier_role_type_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :weight_unit_price, :decimal, public?: true
    attribute :quantity_unit_price, :decimal, public?: true
    attribute :price_unit_price, :decimal, public?: true
    attribute :order_flat_price, :decimal, public?: true
    attribute :order_price_percent, :decimal, public?: true
    attribute :order_item_flat_price, :decimal, public?: true
    attribute :shipping_price_percent, :decimal, public?: true
    attribute :product_feature_group_id, :string, public?: true
    attribute :oversize_unit, :decimal, public?: true
    attribute :oversize_price, :decimal, public?: true
    attribute :feature_percent, :decimal, public?: true
    attribute :feature_price, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_store_shipment_meth, UniboExPoc.Ofbiz.Shipment.ProductStoreShipmentMeth do
      public? true
      source_attribute :product_store_ship_meth_id
      attribute_type :string
    end
    belongs_to :party, UniboExPoc.Ofbiz.Shipment.Party do
      public? true
      attribute_type :string
    end
    belongs_to :role_type, UniboExPoc.Ofbiz.Shipment.RoleType do
      public? true
      attribute_type :string
    end
    belongs_to :weight_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :quantity_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :price_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :to_geo, UniboExPoc.Ofbiz.Shipment.Geo do
      public? true
      source_attribute :geo_id_to
      attribute_type :string
    end
    belongs_to :from_geo, UniboExPoc.Ofbiz.Shipment.Geo do
      public? true
      source_attribute :geo_id_from
      attribute_type :string
    end
    belongs_to :weight_quantity_break, UniboExPoc.Ofbiz.Shipment.QuantityBreak do
      public? true
      source_attribute :weight_break_id
      attribute_type :string
    end
    belongs_to :quantity_quantity_break, UniboExPoc.Ofbiz.Shipment.QuantityBreak do
      public? true
      source_attribute :quantity_break_id
      attribute_type :string
    end
    belongs_to :price_quantity_break, UniboExPoc.Ofbiz.Shipment.QuantityBreak do
      public? true
      source_attribute :price_break_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
