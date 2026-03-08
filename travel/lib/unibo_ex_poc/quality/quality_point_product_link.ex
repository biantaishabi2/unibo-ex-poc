defmodule UniboExPoc.Quality.QualityPointProductLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Quality,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "质量点-产品桥接占位实体"
  end

  postgres do
    table "quality_point_product_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :quality_quality_point_product_link

    queries do
      get :get_quality_quality_point_product_link, :read
      list :list_quality_quality_point_product_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :quality_point, UniboExPoc.Quality.QualityPoint do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboExPoc.Quality.Product do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
