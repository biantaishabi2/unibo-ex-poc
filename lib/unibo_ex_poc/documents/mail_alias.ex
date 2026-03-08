defmodule UniboV4.Documents.MailAlias do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "邮件别名占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "documents_mail_aliases"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_mail_alias

    queries do
      get :get_documents_mail_alias, :read
      list :list_documents_mail_aliass, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :alias_name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
