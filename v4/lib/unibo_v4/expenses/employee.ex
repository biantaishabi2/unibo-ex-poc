defmodule UniboV4.Expenses.Employee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "expenses_employees"
    repo UniboV4.Repo
  end

  graphql do
    type :expenses_employee

    queries do
      get :get_expenses_employee, :read
      list :list_expenses_employees, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :work_email, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
