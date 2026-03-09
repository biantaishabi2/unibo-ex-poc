# Workflow: shipment_box_type_maintain_flow — 标准箱型维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentBoxType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "标准箱型定义，记录箱型名称、最大承重、最大容积和默认尺寸"
  end

  postgres do
    table "delivery_shipment_box_types"
    repo UniboExPoc.Repo
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
    attribute :shipment_box_type_id, :string do
      public? true
      description "OFBiz 箱型编码"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "箱型名称"
    end
    attribute :description, :string do
      public? true
      description "箱型描述"
    end
    attribute :max_weight, :decimal do
      public? true
      description "最大承重"
    end
    attribute :max_volume, :decimal do
      public? true
      description "最大容积"
    end
    attribute :box_length, :decimal do
      public? true
      description "默认箱长"
    end
    attribute :box_width, :decimal do
      public? true
      description "默认箱宽"
    end
    attribute :box_height, :decimal do
      public? true
      description "默认箱高"
    end
    attribute :dimension_uom_id, :string do
      public? true
      description "尺寸单位"
    end
    attribute :weight_uom_id, :string do
      public? true
      description "重量单位"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :packages, UniboExPoc.Delivery.ShipmentPackage do
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
    end
    update :update do
      primary? true
      accept [:name, :description, :max_weight, :max_volume, :box_length, :box_width, :box_height]
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:packages]
  end

end
