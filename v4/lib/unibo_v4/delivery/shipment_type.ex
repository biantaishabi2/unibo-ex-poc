# Workflow: shipment_type_maintain_flow — 发货单类型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_shipment_types"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_shipment_type

    queries do
      get :get_delivery_shipment_type, :read
      list :list_delivery_shipment_types, :read
    end

    mutations do
      create :create_delivery_shipment_type, :create
      update :update_delivery_shipment_type, :update
      destroy :delete_delivery_shipment_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :parent_shipment_type, UniboV4.Delivery.ShipmentType do
      public? true
      source_attribute :parent_type_id
    end
    has_many :child_types, UniboV4.Delivery.ShipmentType do
      public? true
      destination_attribute :parent_type_id
    end
    has_many :shipments, UniboV4.Delivery.Shipment do
      public? true
      destination_attribute :shipment_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_type_id, :description, :has_table]
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
      accept [:description]
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
