defmodule UniboExPoc.Fleet.HrEmployee do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "HR 域员工占位实体（跨域引用，最小字段），Driver 通过此实体关联 HR 域"
  end

  postgres do
    table "fleet_hr_employees"
    repo UniboExPoc.Repo
  end

  graphql do
    type :fleet_hr_employee

    queries do
      get :get_fleet_hr_employee, :read
      list :list_fleet_hr_employees, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      public? true
      description "员工姓名"
    end
  end

  actions do
    defaults [:read, :update]
  end

end
