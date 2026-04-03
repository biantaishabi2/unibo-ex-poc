defmodule UniboExPoc.HR.ExpenseSheet do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "报销汇总单（跨域引用占位，实体定义在 Expenses 域）"
  end

  postgres do
    table "hr_expense_sheets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_expense_sheet

    queries do
      get :get_hr_expense_sheet, :read
      list :list_hr_expense_sheets, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  actions do
    defaults [:read, :update]
  end

end
