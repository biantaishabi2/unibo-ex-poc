defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetIdent do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_idents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_ident

    queries do
      get :get_accounting_fixed_asset_ident, :read
      list :list_accounting_fixed_asset_idents, :read
    end

    mutations do
      create :create_accounting_fixed_asset_ident, :create
      update :update_accounting_fixed_asset_ident, :update
      destroy :delete_accounting_fixed_asset_ident, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :id_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
      public? true
    end
    belongs_to :fixed_asset_ident_type, UniboExPoc.Ofbiz.Accounting.FixedAssetIdentType do
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
