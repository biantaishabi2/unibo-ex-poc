defmodule UniboExPoc.Documents.Group do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "用户组占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "documents_groups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_group

    queries do
      get :get_documents_group, :read
      list :list_documents_groups, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
