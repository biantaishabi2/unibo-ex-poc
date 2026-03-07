defmodule UniboExPoc.Ofbiz.Accounting.PartyFixedAssetAssignment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_party_fixed_asset_assignments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_party_fixed_asset_assignment

    queries do
      get :get_accounting_party_fixed_asset_assignment, :read
      list :list_accounting_party_fixed_asset_assignments, :read
    end

    mutations do
      create :create_accounting_party_fixed_asset_assignment, :create
      update :update_accounting_party_fixed_asset_assignment, :update
      destroy :delete_accounting_party_fixed_asset_assignment, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :allocated_date, :utc_datetime, public?: true
    attribute :status_id, :string, public?: true
    attribute :comments, :string, public?: true
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
