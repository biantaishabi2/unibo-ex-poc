defmodule UniboV4.Expenses.AccountMove do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "expenses_account_moves"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
