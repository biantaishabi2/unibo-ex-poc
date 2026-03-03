defmodule UniboV4.Delivery.Delivery.Party do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "delivery_parties"
    repo UniboV4.Repo
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
