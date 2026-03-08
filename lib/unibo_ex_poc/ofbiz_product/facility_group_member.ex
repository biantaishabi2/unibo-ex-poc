defmodule UniboV4.Ofbiz.Product.FacilityGroupMember do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_facility_group_members"
    repo UniboV4.Repo
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
    belongs_to :facility, UniboV4.Ofbiz.Product.Facility do
      public? true
    end
    belongs_to :facility_group, UniboV4.Ofbiz.Product.FacilityGroup do
      public? true
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
