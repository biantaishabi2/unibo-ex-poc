defmodule UniboExPoc.Ofbiz.Shipment.ShipmentPackageRouteSeg do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_package_route_segs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_package_route_seg

    queries do
      get :get_shipment_shipment_package_route_seg, :read
      list :list_shipment_shipment_package_route_segs, :read
    end

    mutations do
      create :create_shipment_shipment_package_route_seg, :create
      update :update_shipment_shipment_package_route_seg, :update
      destroy :delete_shipment_shipment_package_route_seg, :destroy
    end

  end

  attributes do
    attribute :shipment_package_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shipment_route_segment_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :tracking_code, :string, public?: true
    attribute :box_number, :string, public?: true
    attribute :label_image, :string, public?: true
    attribute :label_intl_sign_image, :string, public?: true
    attribute :label_html, :string, public?: true
    attribute :label_printed, :boolean, public?: true
    attribute :international_invoice, :string, public?: true
    attribute :package_transport_cost, :decimal, public?: true
    attribute :package_service_cost, :decimal, public?: true
    attribute :package_other_cost, :decimal, public?: true
    attribute :cod_amount, :decimal, public?: true
    attribute :insured_amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :currency_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
