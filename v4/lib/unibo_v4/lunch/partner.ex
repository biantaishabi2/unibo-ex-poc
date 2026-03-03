defmodule UniboV4.Lunch.Partner do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "lunch_partners"
    repo UniboV4.Repo
  end

  graphql do
    type :lunch_partner

    queries do
      get :get_lunch_partner, :read
      list :list_lunch_partners, :read
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
