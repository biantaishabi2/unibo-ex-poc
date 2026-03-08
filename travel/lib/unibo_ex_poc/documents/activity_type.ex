defmodule UniboExPoc.Documents.ActivityType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "活动类型占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "documents_activity_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_activity_type

    queries do
      get :get_documents_activity_type, :read
      list :list_documents_activity_types, :read
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
