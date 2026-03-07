defmodule UniboExPoc.Payment.Invoice do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "发票占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "payment_invoices"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_invoice

    queries do
      get :get_payment_invoice, :read
      list :list_payment_invoices, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      public? true
      description "发票编号"
    end
  end

  actions do
    defaults [:read, :update]
  end

end
