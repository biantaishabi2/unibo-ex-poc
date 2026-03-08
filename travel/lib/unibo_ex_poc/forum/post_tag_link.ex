defmodule UniboExPoc.Forum.PostTagLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "帖子与标签关联桥接"
  end

  postgres do
    table "forum_post_tag_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :forum_post_tag_link

    queries do
      get :get_forum_post_tag_link, :read
      list :list_forum_post_tag_links, :read
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
    belongs_to :tag, UniboExPoc.Forum.Tag do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
