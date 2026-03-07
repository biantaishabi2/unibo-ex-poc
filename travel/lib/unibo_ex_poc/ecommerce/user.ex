defmodule UniboExPoc.Ecommerce.User do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "用户占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "ecommerce_users"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_user

    queries do
      get :get_ecommerce_user, :read
      list :list_ecommerce_users, :read
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
