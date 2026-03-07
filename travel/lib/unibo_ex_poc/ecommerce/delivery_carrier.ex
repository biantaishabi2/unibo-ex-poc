defmodule UniboExPoc.Ecommerce.DeliveryCarrier do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "物流方式占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "ecommerce_delivery_carriers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_delivery_carrier

    queries do
      get :get_ecommerce_delivery_carrier, :read
      list :list_ecommerce_delivery_carriers, :read
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
