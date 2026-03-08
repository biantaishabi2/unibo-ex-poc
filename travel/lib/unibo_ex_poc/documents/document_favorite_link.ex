defmodule UniboExPoc.Documents.DocumentFavoriteLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文档-收藏用户桥接占位实体"
  end

  postgres do
    table "documents_document_favorite_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_document_favorite_link

    queries do
      get :get_documents_document_favorite_link, :read
      list :list_documents_document_favorite_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :document, UniboExPoc.Documents.Document do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Documents.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
