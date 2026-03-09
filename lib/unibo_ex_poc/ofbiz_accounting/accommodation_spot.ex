defmodule UniboExPoc.Ofbiz.Accounting.AccommodationSpot do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_accommodation_spots"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_accommodation_spot

    queries do
      get :get_accounting_accommodation_spot, :read
      list :list_accounting_accommodation_spots, :read
    end

    mutations do
      create :create_accounting_accommodation_spot, :create
      update :update_accounting_accommodation_spot, :update
      destroy :delete_accounting_accommodation_spot, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :accommodation_spot_id, :string, public?: true
    attribute :number_of_spaces, :integer, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :accommodation_class, UniboExPoc.Ofbiz.Accounting.AccommodationClass do
      public? true
    end
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
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
