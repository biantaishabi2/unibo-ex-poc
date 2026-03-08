defmodule UniboExPoc.IoT.Contact do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "联系人占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "io_t_contacts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_contact

    queries do
      get :get_io_t_contact, :read
      list :list_io_t_contacts, :read
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
