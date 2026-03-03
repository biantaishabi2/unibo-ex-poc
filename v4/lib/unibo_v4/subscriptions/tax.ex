defmodule UniboV4.Subscriptions.Tax do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_taxes"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_tax

    queries do
      get :get_subscriptions_tax, :read
      list :list_subscriptions_taxs, :read
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
