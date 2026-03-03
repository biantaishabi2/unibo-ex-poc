defmodule UniboV4.Forum.PostFavoriteLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "forum_post_favorite_links"
    repo UniboV4.Repo
  end

  graphql do
    type :forum_post_favorite_link

    queries do
      get :get_forum_post_favorite_link, :read
      list :list_forum_post_favorite_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :post, UniboV4.Forum.Post do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Forum.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
