defmodule UniboExPoc.Lunch.LunchProductFavoriteUserLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "菜品-收藏用户桥接占位实体"
  end

  postgres do
    table "lunch_product_favorite_user_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_product_favorite_user_link

    queries do
      get :get_lunch_lunch_product_favorite_user_link, :read
      list :list_lunch_lunch_product_favorite_user_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :lunch_product, UniboExPoc.Lunch.LunchProduct do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Lunch.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
