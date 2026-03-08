defmodule UniboV4.Expenses.AccountMove do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "会计凭证占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "expenses_account_moves"
    repo UniboV4.Repo
  end

  graphql do
    type :expenses_account_move

    queries do
      get :get_expenses_account_move, :read
      list :list_expenses_account_moves, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :amount_residual, :decimal, public?: true
  end

  relationships do
    belongs_to :expense_report, UniboV4.Expenses.ExpenseReport do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
