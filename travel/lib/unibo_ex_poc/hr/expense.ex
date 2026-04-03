defmodule UniboExPoc.HR.Expense do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "费用报销单（跨域引用占位，实体定义在 Expenses 域）"
  end

  postgres do
    table "hr_expenses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_expense

    queries do
      get :get_hr_expense, :read
      list :list_hr_expenses, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  actions do
    defaults [:read, :update]
  end

end
