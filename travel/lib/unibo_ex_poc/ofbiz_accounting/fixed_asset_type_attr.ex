defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetTypeAttr do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_type_attr

    queries do
      get :get_accounting_fixed_asset_type_attr, :read
      list :list_accounting_fixed_asset_type_attrs, :read
    end

    mutations do
      create :create_accounting_fixed_asset_type_attr, :create
      update :update_accounting_fixed_asset_type_attr, :update
      destroy :delete_accounting_fixed_asset_type_attr, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset_type, UniboExPoc.Ofbiz.Accounting.FixedAssetType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
