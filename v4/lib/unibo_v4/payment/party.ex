defmodule UniboV4.Payment.Payment.Party do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "payment_parties"
    repo UniboV4.Repo
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
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
