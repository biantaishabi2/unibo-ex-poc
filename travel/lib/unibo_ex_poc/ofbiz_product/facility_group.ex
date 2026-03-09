defmodule UniboExPoc.Ofbiz.Product.FacilityGroup do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_product_facility_group

    queries do
      get :get_ofbiz_product_facility_group, :read
      list :list_ofbiz_product_facility_groups, :read
    end

    mutations do
      create :create_ofbiz_product_facility_group, :create
      update :update_ofbiz_product_facility_group, :update
      destroy :delete_ofbiz_product_facility_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :facility_group_id, :string, public?: true
    attribute :facility_group_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility_group_type, UniboExPoc.Ofbiz.Product.FacilityGroupType do
      public? true
    end
    belongs_to :primary_parent_facility_group, UniboExPoc.Ofbiz.Product.FacilityGroup do
      public? true
      source_attribute :primary_parent_group_id
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
