defmodule UniboExPoc.Marketing.Contact do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "联系人占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "marketing_contacts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_contact

    queries do
      get :get_marketing_contact, :read
      list :list_marketing_contacts, :read
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
