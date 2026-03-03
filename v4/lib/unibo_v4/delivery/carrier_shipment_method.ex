# Workflow: carrier_method_bind_flow — 承运商运输方式绑定管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.Delivery.CarrierShipmentMethod do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_carrier_shipment_methods"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_carrier_shipment_method

    queries do
      get :get_delivery_carrier_shipment_method, :read
      list :list_delivery_carrier_shipment_methods, :read
    end

    mutations do
      create :create_delivery_carrier_shipment_method, :create
      update :update_delivery_carrier_shipment_method, :update
      destroy :delete_delivery_carrier_shipment_method, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role_type_id, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence_number, :integer, public?: true
    attribute :carrier_service_code, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment_method_type, UniboV4.Delivery.Delivery.ShipmentMethodType do
      public? true
    end
    belongs_to :carrier_party, UniboV4.Delivery.Delivery.Party do
      public? true
      source_attribute :party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:role_type_id, :sequence_number, :carrier_service_code]
      validate present(:shipment_method_type_id)
      validate present(:party_id)
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
      accept [:sequence_number, :carrier_service_code]
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
