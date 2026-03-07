defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetDepMethod do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_dep_methods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_dep_method

    queries do
      get :get_accounting_fixed_asset_dep_method, :read
      list :list_accounting_fixed_asset_dep_methods, :read
    end

    mutations do
      create :create_accounting_fixed_asset_dep_method, :create
      update :update_accounting_fixed_asset_dep_method, :update
      destroy :delete_accounting_fixed_asset_dep_method, :destroy
    end

  end

  attributes do
    attribute :depreciation_custom_method_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :fixed_asset_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
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
