defmodule UniboV4.Subscriptions.SalesTeam do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_sales_teams"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_sales_team

    queries do
      get :get_subscriptions_sales_team, :read
      list :list_subscriptions_sales_teams, :read
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
