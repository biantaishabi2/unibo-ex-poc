defmodule UniboExPoc.Ofbiz.Product.ContainerGeoPoint do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_container_geo_points"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_container_geo_point

    queries do
      get :get_product_container_geo_point, :read
      list :list_product_container_geo_points, :read
    end

    mutations do
      create :create_product_container_geo_point, :create
      update :update_product_container_geo_point, :update
      destroy :delete_product_container_geo_point, :destroy
    end

  end

  attributes do
    attribute :geo_point_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :container, UniboExPoc.Ofbiz.Product.Container do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
