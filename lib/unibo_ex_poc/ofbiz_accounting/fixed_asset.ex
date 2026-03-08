defmodule UniboV4.Ofbiz.Accounting.FixedAsset do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_fixed_assets"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_fixed_asset

    queries do
      get :get_accounting_fixed_asset, :read
      list :list_accounting_fixed_assets, :read
    end

    mutations do
      create :create_accounting_fixed_asset, :create
      update :update_accounting_fixed_asset, :update
      destroy :delete_accounting_fixed_asset, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :fixed_asset_id, :string, public?: true
    attribute :instance_of_product_id, :string, public?: true
    attribute :class_enum_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :fixed_asset_name, :string, public?: true
    attribute :acquire_order_id, :string, public?: true
    attribute :acquire_order_item_seq_id, :string, public?: true
    attribute :date_acquired, :utc_datetime, public?: true
    attribute :date_last_serviced, :utc_datetime, public?: true
    attribute :date_next_service, :utc_datetime, public?: true
    attribute :expected_end_of_life, :utc_datetime, public?: true
    attribute :actual_end_of_life, :utc_datetime, public?: true
    attribute :production_capacity, :decimal, public?: true
    attribute :uom_id, :string, public?: true
    attribute :calendar_id, :string, public?: true
    attribute :serial_number, :string, public?: true
    attribute :located_at_facility_id, :string, public?: true
    attribute :located_at_location_seq_id, :string, public?: true
    attribute :salvage_value, :decimal, public?: true
    attribute :depreciation, :decimal, public?: true
    attribute :purchase_cost, :decimal, public?: true
    attribute :purchase_cost_uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :fixed_asset_type, UniboV4.Ofbiz.Accounting.FixedAssetType do
      public? true
    end
    belongs_to :parent_fixed_asset, UniboV4.Ofbiz.Accounting.FixedAsset do
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
