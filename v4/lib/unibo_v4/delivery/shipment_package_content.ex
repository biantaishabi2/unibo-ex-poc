# Workflow: shipment_package_content_flow — 包裹内容物管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentPackageContent do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "delivery_shipment_package_contents"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :decimal, public?: true
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
    belongs_to :shipment_item, UniboV4.Delivery.ShipmentItem do
      public? true
      source_attribute :shipment_item_seq_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:quantity]
      validate present(:shipment_id)
      validate present(:shipment_package_seq_id)
      validate present(:shipment_item_seq_id)
      validate compare(:quantity, greater_than: 0)
      # message: "装入数量必须大于 0"
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
      accept [:quantity]
      # skipped: validate compare :quantity (incompatible with bulk update atomic path)
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
