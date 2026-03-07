defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetMaintOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_maint_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_maint_order

    queries do
      get :get_accounting_fixed_asset_maint_order, :read
      list :list_accounting_fixed_asset_maint_orders, :read
    end

    mutations do
      create :create_accounting_fixed_asset_maint_order, :create
      update :update_accounting_fixed_asset_maint_order, :update
      destroy :delete_accounting_fixed_asset_maint_order, :destroy
    end

  end

  attributes do
    attribute :maint_hist_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :order_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
