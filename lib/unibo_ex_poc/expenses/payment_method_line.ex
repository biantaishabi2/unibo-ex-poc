defmodule UniboV4.Expenses.PaymentMethodLine do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Expenses,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "付款方式行占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "expenses_payment_method_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :expenses_payment_method_line

    queries do
      get :get_expenses_payment_method_line, :read
      list :list_expenses_payment_method_lines, :read
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
