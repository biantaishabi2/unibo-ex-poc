defmodule UniboV4.Subscriptions.PaymentToken do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_payment_tokens"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_payment_token

    queries do
      get :get_subscriptions_payment_token, :read
      list :list_subscriptions_payment_tokens, :read
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
