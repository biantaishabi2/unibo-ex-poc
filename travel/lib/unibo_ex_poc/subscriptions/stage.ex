defmodule UniboExPoc.Subscriptions.Stage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "阶段占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "subscriptions_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :subscriptions_stage

    queries do
      get :get_subscriptions_stage, :read
      list :list_subscriptions_stages, :read
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
