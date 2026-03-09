defmodule UniboExPoc.Expenses.Employee do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "expenses_employees"
    repo UniboExPoc.Repo
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
