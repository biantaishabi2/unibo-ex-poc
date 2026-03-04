# Workflow: package_route_seg_flow — 包裹路段追踪流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update_label
#   create --> update_cost
#   create --> destroy
#   update_label --> mark_printed
#   update_label --> update_cost
#   mark_printed --> update_cost
#   update_cost --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentPackageRouteSeg do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "delivery_shipment_package_route_segs"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :tracking_code, :string, public?: true
    attribute :box_number, :string, public?: true
    attribute :label_image, :string, public?: true
    attribute :label_html, :string, public?: true
    attribute :label_printed, :boolean do
      default false
      public? true
    end
    attribute :package_transport_cost, :decimal, public?: true
    attribute :package_service_cost, :decimal, public?: true
    attribute :package_other_cost, :decimal, public?: true
    attribute :cod_amount, :decimal, public?: true
    attribute :insured_amount, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment, UniboV4.Delivery.Shipment do
      public? true
    end
    belongs_to :shipment_package, UniboV4.Delivery.ShipmentPackage do
      public? true
      source_attribute :shipment_package_seq_id
    end
    belongs_to :route_segment, UniboV4.Delivery.ShipmentRouteSegment do
      public? true
      source_attribute :shipment_route_segment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:tracking_code]
      validate present(:shipment_id)
      validate present(:shipment_package_seq_id)
      validate present(:shipment_route_segment_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update_label do
      accept [:label_image, :label_html, :label_printed]
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
    update :update_cost do
      accept [:package_transport_cost, :package_service_cost, :package_other_cost, :cod_amount, :insured_amount, :currency_uom_id]
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
    update :mark_printed do
      accept []
      change set_attribute(:label_printed, true)
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
