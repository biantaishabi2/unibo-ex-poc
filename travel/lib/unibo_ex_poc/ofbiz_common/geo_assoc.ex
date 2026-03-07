defmodule UniboExPoc.Ofbiz.Common.GeoAssoc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "Geographic Boundary Association"
  end

  postgres do
    table "common_geo_assocs"
    repo UniboExPoc.Repo
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
    attribute :geo_id, :uuid do
      primary_key? true
      allow_nil? false
      public? true
      description "The enclosed geo"
    end
    attribute :geo_id_to, :uuid do
      primary_key? true
      allow_nil? false
      public? true
      description "The enclosing geo"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :main_geo, UniboExPoc.Ofbiz.Common.Geo do
      public? true
      source_attribute :geo_id
      define_attribute? false
    end
    belongs_to :assoc_geo, UniboExPoc.Ofbiz.Common.Geo do
      public? true
      source_attribute :geo_id_to
      define_attribute? false
    end
    belongs_to :geo_assoc_type, UniboExPoc.Ofbiz.Common.GeoAssocType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
