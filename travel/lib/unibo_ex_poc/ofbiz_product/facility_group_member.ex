defmodule UniboExPoc.Ofbiz.Product.FacilityGroupMember do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_group_members"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_facility_group_member

    queries do
      get :get_product_facility_group_member, :read
      list :list_product_facility_group_members, :read
    end

    mutations do
      create :create_product_facility_group_member, :create
      update :update_product_facility_group_member, :update
      destroy :delete_product_facility_group_member, :destroy
    end

  end

  attributes do
    attribute :facility_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :facility_group_id, :uuid do
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facility, UniboExPoc.Ofbiz.Product.Facility do
      public? true
      define_attribute? false
    end
    belongs_to :facility_group, UniboExPoc.Ofbiz.Product.FacilityGroup do
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
