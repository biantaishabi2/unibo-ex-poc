defmodule UniboExPoc.Ofbiz.Product.FacilityContactMech do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_contact_meches"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_facility_contact_mech

    queries do
      get :get_product_facility_contact_mech, :read
      list :list_product_facility_contact_mechs, :read
    end

    mutations do
      create :create_product_facility_contact_mech, :create
      update :update_product_facility_contact_mech, :update
      destroy :delete_product_facility_contact_mech, :destroy
    end

  end

  attributes do
    attribute :facility_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :contact_mech_id, :string do
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
    attribute :extension, :string, public?: true
    attribute :comments, :string, public?: true
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
