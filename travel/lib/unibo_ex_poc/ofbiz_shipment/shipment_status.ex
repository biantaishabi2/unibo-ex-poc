defmodule UniboExPoc.Ofbiz.Shipment.ShipmentStatus do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_shipment_shipment_status

    queries do
      get :get_ofbiz_shipment_shipment_status, :read
      list :list_ofbiz_shipment_shipment_statuss, :read
    end

    mutations do
      create :create_ofbiz_shipment_shipment_status, :create
      update :update_ofbiz_shipment_shipment_status, :update
      destroy :delete_ofbiz_shipment_shipment_status, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :status_item, UniboExPoc.Ofbiz.Shipment.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :shipment, UniboExPoc.Ofbiz.Shipment.Shipment do
      public? true
      attribute_type :string
    end
    belongs_to :change_by_user_login, UniboExPoc.Ofbiz.Shipment.UserLogin do
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
