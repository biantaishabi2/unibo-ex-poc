defmodule UniboV4.Lunch.LunchProductFavoriteUserLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lunch_product_favorite_user_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
