defmodule UniboV4.Documents.DocumentShareLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文档-分享桥接占位实体"
  end

  postgres do
    table "documents_document_share_links"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_document_share_link

    queries do
      get :get_documents_document_share_link, :read
      list :list_documents_document_share_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :document, UniboV4.Documents.Document do
      public? true
      allow_nil? false
    end
    belongs_to :share, UniboV4.Documents.Share do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
