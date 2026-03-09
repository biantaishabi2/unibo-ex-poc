defmodule UniboExPoc.Ofbiz.Marketing.SegmentGroupGeo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "marketing_segment_group_geos"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_segment_group_geo

    queries do
      get :get_marketing_segment_group_geo, :read
      list :list_marketing_segment_group_geos, :read
    end

    mutations do
      create :create_marketing_segment_group_geo, :create
      update :update_marketing_segment_group_geo, :update
      destroy :delete_marketing_segment_group_geo, :destroy
    end

  end

  attributes do
    attribute :geo_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :segment_group, UniboExPoc.Ofbiz.Marketing.SegmentGroup do
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
