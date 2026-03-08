defmodule UniboV4.Documents.DocumentVersion do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文档版本占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "documents_document_versions"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_document_version

    queries do
      get :get_documents_document_version, :read
      list :list_documents_document_versions, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :attachment_id, :uuid, public?: true
  end

  relationships do
    belongs_to :document, UniboV4.Documents.Document do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
