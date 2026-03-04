defmodule UniboV4.Knowledge.ArticleTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "knowledge_article_tag_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
