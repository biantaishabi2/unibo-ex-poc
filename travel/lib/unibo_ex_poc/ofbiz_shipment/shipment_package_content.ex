defmodule UniboExPoc.Ofbiz.Shipment.ShipmentPackageContent do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_package_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_package_content

    queries do
      get :get_shipment_shipment_package_content, :read
      list :list_shipment_shipment_package_contents, :read
    end

    mutations do
      create :create_shipment_shipment_package_content, :create
      update :update_shipment_shipment_package_content, :update
      destroy :delete_shipment_shipment_package_content, :destroy
    end

  end

  attributes do
    attribute :shipment_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shipment_package_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :shipment_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :quantity, :decimal, public?: true
    attribute :sub_product_quantity, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :sub_product, UniboExPoc.Ofbiz.Shipment.Product do
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
