defmodule UniboExPoc.Ofbiz.Product.ProductFacilityAssoc do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_assocs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_facility_assoc

    queries do
      get :get_product_product_facility_assoc, :read
      list :list_product_product_facility_assocs, :read
    end

    mutations do
      create :create_product_product_facility_assoc, :create
      update :update_product_product_facility_assoc, :update
      destroy :delete_product_product_facility_assoc, :destroy
    end

  end

  attributes do
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :facility_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :facility_id_to, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :facility_assoc_type_id, :uuid do
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
    attribute :sequence_num, :integer, public?: true
    attribute :transit_time, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
    belongs_to :from_facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
      source_attribute :facility_id
      define_attribute? false
    end
    belongs_to :to_facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
      source_attribute :facility_id_to
      define_attribute? false
    end
    belongs_to :facility_assoc_type, UniboExPoc.Ofbiz.Product.FacilityAssocType do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
