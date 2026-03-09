# Workflow: shipment_package_flow — 包裹管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentPackage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "包裹，记录打包信息，含箱型、尺寸、重量和保价"
  end

  postgres do
    table "delivery_shipment_packages"
    repo UniboExPoc.Repo
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
    attribute :shipment_package_seq_id, :uuid do
      allow_nil? false
      public? true
      description "包裹序号"
    end
    attribute :date_created, :utc_datetime do
      public? true
      description "打包时间"
    end
    attribute :box_length, :decimal do
      public? true
      description "箱长（覆盖箱型默认值）"
    end
    attribute :box_height, :decimal do
      public? true
      description "箱高（覆盖箱型默认值）"
    end
    attribute :box_width, :decimal do
      public? true
      description "箱宽（覆盖箱型默认值）"
    end
    attribute :dimension_uom_id, :string do
      public? true
      description "尺寸单位"
    end
    attribute :weight, :decimal do
      public? true
      description "包裹实际重量"
    end
    attribute :weight_uom_id, :string do
      public? true
      description "重量单位"
    end
    attribute :insured_value, :decimal do
      public? true
      description "保价金额"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Delivery.Shipment do
      public? true
    end
    belongs_to :box_type, UniboExPoc.Delivery.ShipmentBoxType do
      public? true
      source_attribute :shipment_box_type_id
    end
    has_many :contents, UniboExPoc.Delivery.ShipmentPackageContent do
      public? true
      destination_attribute :shipment_package_seq_id
    end
    has_many :route_segs, UniboExPoc.Delivery.ShipmentPackageRouteSeg do
      public? true
      destination_attribute :shipment_package_seq_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_id, :shipment_package_seq_id, :shipment_box_type_id, :weight, :weight_uom_id, :box_length, :box_height, :box_width, :dimension_uom_id, :insured_value]
      validate present(:shipment_id)
    end
    update :update do
      primary? true
      accept [:weight, :box_length, :box_height, :box_width, :insured_value]
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:contents, :route_segs]
  end

end
