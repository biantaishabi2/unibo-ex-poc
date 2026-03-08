defmodule UniboV4.Subscriptions.Pricelist do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "价格表占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "subscriptions_pricelists"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_pricelist

    queries do
      get :get_subscriptions_pricelist, :read
      list :list_subscriptions_pricelists, :read
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
