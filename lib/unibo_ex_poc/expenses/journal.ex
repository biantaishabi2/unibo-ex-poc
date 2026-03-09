defmodule UniboExPoc.Expenses.Journal do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "日记账占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "expenses_journals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :expenses_journal

    queries do
      get :get_expenses_journal, :read
      list :list_expenses_journals, :read
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
