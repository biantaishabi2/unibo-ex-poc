defmodule UniboExPoc.Documents.Attachment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "附件占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "documents_attachments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_attachment

    queries do
      get :get_documents_attachment, :read
      list :list_documents_attachments, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :file_name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
