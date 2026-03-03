defmodule UniboV4.Expenses.Company do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "expenses_companies"
    repo UniboV4.Repo
  end

  graphql do
    type :expenses_company

    queries do
      get :get_expenses_company, :read
      list :list_expenses_companys, :read
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
