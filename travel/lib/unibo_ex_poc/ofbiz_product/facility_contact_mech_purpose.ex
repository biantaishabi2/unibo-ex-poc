defmodule UniboExPoc.Ofbiz.Product.FacilityContactMechPurpose do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_contact_mech_purposes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_facility_contact_mech_purpose

    queries do
      get :get_product_facility_contact_mech_purpose, :read
      list :list_product_facility_contact_mech_purposes, :read
    end

    mutations do
      create :create_product_facility_contact_mech_purpose, :create
      update :update_product_facility_contact_mech_purpose, :update
      destroy :delete_product_facility_contact_mech_purpose, :destroy
    end

  end

  attributes do
    attribute :contact_mech_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :contact_mech_purpose_type_id, :string do
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
