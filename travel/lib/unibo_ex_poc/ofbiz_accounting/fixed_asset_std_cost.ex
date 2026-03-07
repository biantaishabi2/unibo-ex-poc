defmodule UniboExPoc.Ofbiz.Accounting.FixedAssetStdCost do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_asset_std_costs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_fixed_asset_std_cost

    queries do
      get :get_accounting_fixed_asset_std_cost, :read
      list :list_accounting_fixed_asset_std_costs, :read
    end

    mutations do
      create :create_accounting_fixed_asset_std_cost, :create
      update :update_accounting_fixed_asset_std_cost, :update
      destroy :delete_accounting_fixed_asset_std_cost, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :amount_uom_id, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
      public? true
    end
    belongs_to :fixed_asset_std_cost_type, UniboExPoc.Ofbiz.Accounting.FixedAssetStdCostType do
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
