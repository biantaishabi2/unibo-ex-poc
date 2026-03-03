defmodule UniboV4.Lunch.LunchProductFavoriteUserLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "lunch_product_favorite_user_links"
    repo UniboV4.Repo
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
    belongs_to :lunch_product, UniboV4.Lunch.LunchProduct do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Lunch.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
