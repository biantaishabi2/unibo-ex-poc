# Workflow: shipment_box_type_maintain_flow — 标准箱型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentBoxType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_shipment_box_types"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_shipment_box_type

    queries do
      get :get_delivery_shipment_box_type, :read
      list :list_delivery_shipment_box_types, :read
    end

    mutations do
      create :create_delivery_shipment_box_type, :create
      update :update_delivery_shipment_box_type, :update
      destroy :delete_delivery_shipment_box_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_box_type_id, :string, public?: true
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :max_weight, :decimal, public?: true
    attribute :max_volume, :decimal, public?: true
    attribute :box_length, :decimal, public?: true
    attribute :box_width, :decimal, public?: true
    attribute :box_height, :decimal, public?: true
    attribute :dimension_uom_id, :string, public?: true
    attribute :weight_uom_id, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :packages, UniboV4.Delivery.ShipmentPackage do
      public? true
      destination_attribute :shipment_box_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_box_type_id, :name, :description, :max_weight, :max_volume, :box_length, :box_width, :box_height, :dimension_uom_id, :weight_uom_id]
      validate present(:name)
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
      accept [:name, :description, :max_weight, :max_volume, :box_length, :box_width, :box_height]
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
