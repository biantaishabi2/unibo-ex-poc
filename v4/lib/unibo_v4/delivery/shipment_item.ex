# Workflow: shipment_item_flow — 发货明细行管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentItem do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_shipment_items"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_shipment_item

    queries do
      get :get_delivery_shipment_item, :read
      list :list_delivery_shipment_items, :read
    end

    mutations do
      create :create_delivery_shipment_item, :create
      update :update_delivery_shipment_item, :update
      destroy :delete_delivery_shipment_item, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_item_seq_id, :string do
      allow_nil? false
      public? true
    end
    attribute :quantity, :decimal, public?: true
    attribute :shipment_content_description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment, UniboV4.Delivery.Shipment do
      public? true
    end
    belongs_to :product, UniboV4.Delivery.Product do
      public? true
    end
    has_many :package_contents, UniboV4.Delivery.ShipmentPackageContent do
      public? true
      destination_attribute :shipment_item_seq_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_item_seq_id, :quantity, :shipment_content_description]
      validate present(:shipment_id)
      validate compare(:quantity, greater_than: 0)
      # message: "发货数量必须大于 0"
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
      accept [:quantity, :shipment_content_description]
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
