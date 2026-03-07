defmodule UniboExPoc.Ofbiz.Shipment.ShipmentTimeEstimate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "shipment_time_estimates"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_time_estimate

    queries do
      get :get_shipment_shipment_time_estimate, :read
      list :list_shipment_shipment_time_estimates, :read
    end

    mutations do
      create :create_shipment_shipment_time_estimate, :create
      update :update_shipment_shipment_time_estimate, :update
      destroy :delete_shipment_shipment_time_estimate, :destroy
    end

  end

  attributes do
    attribute :shipment_method_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :geo_id_to, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :geo_id_from, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :lead_time, :decimal, public?: true
    attribute :sequence_number, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :to_geo, UniboExPoc.Ofbiz.Shipment.Geo do
      public? true
      source_attribute :geo_id_to
      define_attribute? false
      attribute_type :string
    end
    belongs_to :from_geo, UniboExPoc.Ofbiz.Shipment.Geo do
      public? true
      source_attribute :geo_id_from
      define_attribute? false
      attribute_type :string
    end
    belongs_to :time_unit_uom, UniboExPoc.Ofbiz.Shipment.Uom do
      public? true
      source_attribute :lead_time_uom_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
