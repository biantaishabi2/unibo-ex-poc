defmodule UniboExPoc.Delivery.Party do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "参与方占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "delivery_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_party

    queries do
      get :get_delivery_party, :read
      list :list_delivery_partys, :read
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
