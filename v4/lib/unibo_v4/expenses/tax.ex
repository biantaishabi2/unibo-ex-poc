defmodule UniboV4.Expenses.Tax do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "expenses_taxes"
    repo UniboV4.Repo
  end

  graphql do
    type :expenses_tax

    queries do
      get :get_expenses_tax, :read
      list :list_expenses_taxs, :read
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
