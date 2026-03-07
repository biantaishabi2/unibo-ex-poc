defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetTypeGlAccount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_type_gl_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_type_gl_account

    queries do
      get :get_accounting_fixed_asset_type_gl_account, :read
      list :list_accounting_fixed_asset_type_gl_accounts, :read
    end

    mutations do
      create :create_accounting_fixed_asset_type_gl_account, :create
      update :update_accounting_fixed_asset_type_gl_account, :update
      destroy :delete_accounting_fixed_asset_type_gl_account, :destroy
    end

  end

  attributes do
    attribute :fixed_asset_type_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "映射的固定资产类型。此字段可设置为_NA_以为所有类型或特定资产定义映射（由fixedAssetId字段中的id指定）。"
    end
    attribute :fixed_asset_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
      description "映射的固定资产id。此字段可设置为_NA_以为给定类型的所有资产定义映射（由fixedAssetTypeId字段中的id指定）。"
    end
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset_type, UniboExPoc.Ofbiz.Accounting.FixedAssetType do
      public? true
      define_attribute? false
    end
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
      public? true
      define_attribute? false
    end
    belongs_to :asset_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
    belongs_to :accumulated_depreciation_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
      source_attribute :acc_dep_gl_account_id
    end
    belongs_to :depreciation_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
      source_attribute :dep_gl_account_id
    end
    belongs_to :profit_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
    belongs_to :loss_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
