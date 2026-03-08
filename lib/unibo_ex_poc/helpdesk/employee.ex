defmodule UniboV4.Helpdesk.Employee do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "helpdesk_employees"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_employee

    queries do
      get :get_helpdesk_employee, :read
      list :list_helpdesk_employees, :read
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
