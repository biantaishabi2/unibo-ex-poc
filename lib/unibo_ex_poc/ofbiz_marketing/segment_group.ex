defmodule UniboV4.Ofbiz.Marketing.SegmentGroup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_segment_groups"
    repo UniboV4.Repo
  end

  graphql do
    type :marketing_segment_group

    queries do
      get :get_marketing_segment_group, :read
      list :list_marketing_segment_groups, :read
    end

    mutations do
      create :create_marketing_segment_group, :create
      update :update_marketing_segment_group, :update
      destroy :delete_marketing_segment_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :segment_group_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :product_store_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :segment_group_type, UniboV4.Ofbiz.Marketing.SegmentGroupType do
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
