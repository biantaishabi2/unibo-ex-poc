defmodule UniboExPoc.Ofbiz.Product.FacilityAttribute do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_facility_attribute

    queries do
      get :get_product_facility_attribute, :read
      list :list_product_facility_attributes, :read
    end

    mutations do
      create :create_product_facility_attribute, :create
      update :update_product_facility_attribute, :update
      destroy :delete_product_facility_attribute, :destroy
    end

  end

  attributes do
    attribute :facility_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
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
