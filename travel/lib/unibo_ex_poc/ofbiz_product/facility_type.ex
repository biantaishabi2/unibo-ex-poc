defmodule UniboExPoc.Ofbiz.Product.FacilityType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_facility_type

    queries do
      get :get_ofbiz_product_facility_type, :read
      list :list_ofbiz_product_facility_types, :read
    end

    mutations do
      create :create_ofbiz_product_facility_type, :create
      update :update_ofbiz_product_facility_type, :update
      destroy :delete_ofbiz_product_facility_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :facility_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_facility_type, UniboExPoc.Ofbiz.Product.FacilityType do
      public? true
      source_attribute :parent_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
