defmodule UniboExPoc.Payment.Party do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "参与方占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "payment_parties"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_party

    queries do
      get :get_payment_party, :read
      list :list_payment_partys, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      public? true
      description "参与方名称"
    end
  end

  actions do
    defaults [:read, :update]
  end

end
