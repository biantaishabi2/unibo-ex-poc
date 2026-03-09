defmodule UniboExPoc.Forum.PostFavoriteLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "帖子与收藏用户关联桥接"
  end

  postgres do
    table "forum_post_favorite_links"
    repo UniboExPoc.Repo
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
    belongs_to :post, UniboExPoc.Forum.Post do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Forum.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
