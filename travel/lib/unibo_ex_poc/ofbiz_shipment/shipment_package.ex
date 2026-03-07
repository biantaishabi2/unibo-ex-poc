defmodule UniboExPoc.Ofbiz.Shipment.ShipmentPackage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_packages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_package

    queries do
      get :get_shipment_shipment_package, :read
      list :list_shipment_shipment_packages, :read
    end

    mutations do
      create :create_shipment_shipment_package, :create
      update :update_shipment_shipment_package, :update
      destroy :delete_shipment_shipment_package, :destroy
    end

  end

  attributes do
    attribute :shipment_package_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :date_created, :utc_datetime, public?: true
    attribute :box_length, :decimal do
      public? true
      description "此字段存储包裹的长度；如果指定了发货箱类型，则覆盖其中指定的尺寸；当没有适用的发货箱类型时，此字段用于直接指定尺寸"
    end
    attribute :box_height, :decimal do
      public? true
      description "此字段存储包裹的高度；如果指定了发货箱类型，则覆盖其中指定的尺寸；当没有适用的发货箱类型时，此字段用于直接指定尺寸"
    end
    attribute :box_width, :decimal do
      public? true
      description "此字段存储包裹的宽度；如果指定了发货箱类型，则覆盖其中指定的尺寸；当没有适用的发货箱类型时，此字段用于直接指定尺寸"
    end
    attribute :weight, :decimal, public?: true
    attribute :insured_value, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :shipment_box_type, UniboExPoc.Ofbiz.Shipment.ShipmentBoxType do
      public? true
      attribute_type :string
    end
    has_many :carrier_shipment_box_type, UniboExPoc.Ofbiz.Shipment.CarrierShipmentBoxType do
      public? true
      source_attribute :shipment_box_type_id
      destination_attribute :shipment_box_type_id
    end
    belongs_to :dimension_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
    belongs_to :weight_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
    archive_related [:carrier_shipment_box_type]
  end

end
