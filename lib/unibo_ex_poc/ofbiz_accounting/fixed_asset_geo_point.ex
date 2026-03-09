defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetGeoPoint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_geo_points"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_geo_point

    queries do
      get :get_accounting_fixed_asset_geo_point, :read
      list :list_accounting_fixed_asset_geo_points, :read
    end

    mutations do
      create :create_accounting_fixed_asset_geo_point, :create
      update :update_accounting_fixed_asset_geo_point, :update
      destroy :delete_accounting_fixed_asset_geo_point, :destroy
    end

  end

  attributes do
    attribute :geo_point_id, :string do
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
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
