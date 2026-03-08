defmodule UniboV4.Ofbiz.Common.UomGroup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Unit Of Measure Group"
  end

  postgres do
    table "common_uom_groups"
    repo UniboV4.Repo
  end

  graphql do
    type :common_uom_group

    queries do
      get :get_common_uom_group, :read
      list :list_common_uom_groups, :read
    end

    mutations do
      create :create_common_uom_group, :create
      update :update_common_uom_group, :update
      destroy :delete_common_uom_group, :destroy
    end

  end

  attributes do
    attribute :uom_group_id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :uom, UniboV4.Ofbiz.Common.Uom do
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
