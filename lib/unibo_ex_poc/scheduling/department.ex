defmodule UniboExPoc.Scheduling.Department do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域引用 HR.Department（科室）"
  end

  postgres do
    table "scheduling_departments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :scheduling_department

    queries do
      get :get_scheduling_department, :read
      list :list_scheduling_departments, :read
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
