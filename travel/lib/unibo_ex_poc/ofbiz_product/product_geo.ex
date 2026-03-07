defmodule UniboExPoc.Ofbiz.Product.ProductGeo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_geos"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_product_geo

    queries do
      get :get_product_product_geo, :read
      list :list_product_product_geos, :read
    end

    mutations do
      create :create_product_product_geo, :create
      update :update_product_product_geo, :update
      destroy :delete_product_product_geo, :destroy
    end

  end

  attributes do
    attribute :product_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :geo_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :product_geo_enum_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product, UniboExPoc.Ofbiz.Product.Product do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
