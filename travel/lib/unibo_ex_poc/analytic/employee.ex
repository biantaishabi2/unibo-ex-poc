defmodule UniboExPoc.Analytic.Employee do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Analytic,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "analytic_employees"
    repo UniboExPoc.Repo
  end

  graphql do
    type :analytic_employee

    queries do
      get :get_analytic_employee, :read
      list :list_analytic_employees, :read
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
