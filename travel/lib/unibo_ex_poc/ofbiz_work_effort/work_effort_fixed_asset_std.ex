defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortFixedAssetStd do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_fixed_asset_stds"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_fixed_asset_std

    queries do
      get :get_work_effort_work_effort_fixed_asset_std, :read
      list :list_work_effort_work_effort_fixed_asset_stds, :read
    end

    mutations do
      create :create_work_effort_work_effort_fixed_asset_std, :create
      update :update_work_effort_work_effort_fixed_asset_std, :update
      destroy :delete_work_effort_work_effort_fixed_asset_std, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :estimated_quantity, :float, public?: true
    attribute :estimated_duration, :float, public?: true
    attribute :estimated_cost, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :fixed_asset_type, UniboExPoc.Ofbiz.WorkEffort.FixedAssetType do
      public? true
      attribute_type :string
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
