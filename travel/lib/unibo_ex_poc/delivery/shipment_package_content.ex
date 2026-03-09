# Workflow: shipment_package_content_flow — 包裹内容物管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentPackageContent do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "包裹内容物关联，记录每个包裹中包含的发货明细行及其数量"
  end

  postgres do
    table "delivery_shipment_package_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_shipment_package_content

    queries do
      get :get_delivery_shipment_package_content, :read
      list :list_delivery_shipment_package_contents, :read
    end

    mutations do
      create :create_delivery_shipment_package_content, :create
      update :update_delivery_shipment_package_content, :update
      destroy :delete_delivery_shipment_package_content, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :decimal do
      public? true
      description "装入该包裹的数量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Delivery.Shipment do
      public? true
    end
    belongs_to :shipment_package, UniboExPoc.Delivery.ShipmentPackage do
      public? true
      source_attribute :shipment_package_seq_id
    end
    belongs_to :shipment_item, UniboExPoc.Delivery.ShipmentItem do
      public? true
      source_attribute :shipment_item_seq_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_id, :shipment_package_seq_id, :shipment_item_seq_id, :quantity]
      validate present(:shipment_id)
      validate present(:shipment_package_seq_id)
      validate present(:shipment_item_seq_id)
      validate compare(:quantity, greater_than: 0)
      # message: "装入数量必须大于 0"
    end
    update :update do
      primary? true
      accept [:quantity]
      # skipped: validate compare :quantity (incompatible with bulk update atomic path)
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
