# Workflow: shipment_method_type_maintain_flow — 运输方式维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.Delivery.ShipmentMethodType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_shipment_method_types"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_shipment_method_type

    queries do
      get :get_delivery_shipment_method_type, :read
      list :list_delivery_shipment_method_types, :read
    end

    mutations do
      create :create_delivery_shipment_method_type, :create
      update :update_delivery_shipment_method_type, :update
      destroy :delete_delivery_shipment_method_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_method_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :carrier_shipment_methods, UniboV4.Delivery.Delivery.CarrierShipmentMethod do
      public? true
      destination_attribute :shipment_method_type_id
    end
    has_many :cost_estimates, UniboV4.Delivery.Delivery.ShipmentCostEstimate do
      public? true
      destination_attribute :shipment_method_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_method_type_id, :description, :sequence_num]
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
      accept [:description, :sequence_num]
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
