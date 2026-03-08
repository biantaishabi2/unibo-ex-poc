# Workflow: shipment_type_maintain_flow — 发货单类型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "发货单类型字典，支持层级分类"
  end

  postgres do
    table "delivery_shipment_types"
    repo UniboExPoc.Repo
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
    attribute :shipment_type_id, :string do
      public? true
      description "OFBiz 类型编码"
    end
    attribute :has_table, :boolean do
      public? true
      description "是否有子表扩展"
    end
    attribute :description, :string do
      public? true
      description "类型描述"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_shipment_type, UniboExPoc.Delivery.ShipmentType do
      public? true
      source_attribute :parent_type_id
    end
    has_many :child_types, UniboExPoc.Delivery.ShipmentType do
      public? true
      source_attribute :parent_type_id
      destination_attribute :parent_type_id
    end
    has_many :shipments, UniboExPoc.Delivery.Shipment do
      public? true
      source_attribute :shipment_type_id
      destination_attribute :shipment_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_type_id, :parent_type_id, :description, :has_table]
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:child_types, :shipments]
  end

end
