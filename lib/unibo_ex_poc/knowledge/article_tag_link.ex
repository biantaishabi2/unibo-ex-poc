defmodule UniboV4.Knowledge.ArticleTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文章与标签关联桥接"
  end

  postgres do
    table "knowledge_article_tag_links"
    repo UniboV4.Repo
  end

  graphql do
    type :knowledge_article_tag_link

    queries do
      get :get_knowledge_article_tag_link, :read
      list :list_knowledge_article_tag_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :article, UniboV4.Knowledge.Article do
      public? true
      allow_nil? false
    end
    belongs_to :tag, UniboV4.Knowledge.Tag do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
