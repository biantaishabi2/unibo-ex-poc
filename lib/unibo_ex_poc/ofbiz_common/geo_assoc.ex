defmodule UniboV4.Ofbiz.Common.GeoAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Geographic Boundary Association"
  end

  postgres do
    table "common_geo_assocs"
    repo UniboV4.Repo
  end

  graphql do
    type :common_geo_assoc

    queries do
      get :get_common_geo_assoc, :read
      list :list_common_geo_assocs, :read
    end

    mutations do
      create :create_common_geo_assoc, :create
      update :update_common_geo_assoc, :update
      destroy :delete_common_geo_assoc, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :main_geo, UniboV4.Ofbiz.Common.Geo do
      public? true
      source_attribute :geo_id
    end
    belongs_to :assoc_geo, UniboV4.Ofbiz.Common.Geo do
      public? true
      source_attribute :geo_id_to
    end
    belongs_to :geo_assoc_type, UniboV4.Ofbiz.Common.GeoAssocType do
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
