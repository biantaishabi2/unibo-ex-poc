# Workflow: shipment_package_flow — 包裹管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentPackage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_shipment_packages"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_shipment_package

    queries do
      get :get_delivery_shipment_package, :read
      list :list_delivery_shipment_packages, :read
    end

    mutations do
      create :create_delivery_shipment_package, :create
      update :update_delivery_shipment_package, :update
      destroy :delete_delivery_shipment_package, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_package_seq_id, :string do
      allow_nil? false
      public? true
    end
    attribute :date_created, :utc_datetime, public?: true
    attribute :box_length, :decimal, public?: true
    attribute :box_height, :decimal, public?: true
    attribute :box_width, :decimal, public?: true
    attribute :dimension_uom_id, :string, public?: true
    attribute :weight, :decimal, public?: true
    attribute :weight_uom_id, :string, public?: true
    attribute :insured_value, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment, UniboV4.Delivery.Shipment do
      public? true
    end
    belongs_to :box_type, UniboV4.Delivery.ShipmentBoxType do
      public? true
      source_attribute :shipment_box_type_id
    end
    has_many :contents, UniboV4.Delivery.ShipmentPackageContent do
      public? true
      destination_attribute :shipment_package_seq_id
    end
    has_many :route_segs, UniboV4.Delivery.ShipmentPackageRouteSeg do
      public? true
      destination_attribute :shipment_package_seq_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_package_seq_id, :weight, :weight_uom_id, :box_length, :box_height, :box_width, :dimension_uom_id, :insured_value]
      validate present(:shipment_id)
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
      accept [:weight, :box_length, :box_height, :box_width, :insured_value]
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
