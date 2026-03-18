defmodule HospitalScheduling.Scheduling.Employee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 HR.Employee（护士/医护人员）"
  end

  postgres do
    table "scheduling_employees"
    repo HospitalScheduling.Repo
  end

  graphql do
    type :scheduling_employee

    queries do
      get :get_scheduling_employee, :read
      list :list_scheduling_employees, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :employee_code, :string, public?: true
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
