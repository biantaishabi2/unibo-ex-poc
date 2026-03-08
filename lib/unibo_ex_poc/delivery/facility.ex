defmodule UniboV4.Delivery.Facility do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "设施/仓库占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "delivery_facilities"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_facility

    queries do
      get :get_delivery_facility, :read
      list :list_delivery_facilitys, :read
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
