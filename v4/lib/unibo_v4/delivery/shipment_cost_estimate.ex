# Workflow: cost_estimate_maintain_flow — 运费估算规则维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.Delivery.ShipmentCostEstimate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_shipment_cost_estimates"
    repo UniboV4.Repo
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
    attribute :shipment_cost_estimate_id, :string, public?: true
    attribute :carrier_role_type_id, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :geo_id_to, :string, public?: true
    attribute :geo_id_from, :string, public?: true
    attribute :weight_break_id, :string, public?: true
    attribute :weight_uom_id, :string, public?: true
    attribute :weight_unit_price, :decimal, public?: true
    attribute :quantity_break_id, :string, public?: true
    attribute :quantity_uom_id, :string, public?: true
    attribute :quantity_unit_price, :decimal, public?: true
    attribute :price_break_id, :string, public?: true
    attribute :price_uom_id, :string, public?: true
    attribute :price_unit_price, :decimal, public?: true
    attribute :order_flat_price, :decimal, public?: true
    attribute :order_price_percent, :decimal, public?: true
    attribute :order_item_flat_price, :decimal, public?: true
    attribute :shipping_price_percent, :decimal, public?: true
    attribute :oversize_unit, :decimal, public?: true
    attribute :oversize_price, :decimal, public?: true
    attribute :feature_percent, :decimal, public?: true
    attribute :feature_price, :decimal, public?: true
    attribute :product_feature_group_id, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment_method_type, UniboV4.Delivery.Delivery.ShipmentMethodType do
      public? true
    end
    belongs_to :carrier_party, UniboV4.Delivery.Delivery.Party do
      public? true
    end
    belongs_to :party, UniboV4.Delivery.Delivery.Party do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_cost_estimate_id, :carrier_role_type_id, :product_store_id, :geo_id_from, :geo_id_to, :weight_unit_price, :weight_uom_id, :weight_break_id, :quantity_unit_price, :quantity_uom_id, :quantity_break_id, :price_unit_price, :price_uom_id, :price_break_id, :order_flat_price, :order_price_percent, :order_item_flat_price, :shipping_price_percent, :oversize_unit, :oversize_price, :feature_percent, :feature_price, :product_feature_group_id]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:weight_unit_price, :order_flat_price, :order_price_percent, :order_item_flat_price, :oversize_price, :shipping_price_percent]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

end
