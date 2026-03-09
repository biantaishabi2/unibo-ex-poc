defmodule UniboExPoc.Project.Employee do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域员工占位实体"
  end

  postgres do
    table "project_employees"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_employee

    queries do
      get :get_project_employee, :read
      list :list_project_employees, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :hourly_cost, :decimal do
      public? true
      description "小时成本（用于工时成本金额计算）"
    end
  end

  relationships do
    belongs_to :user, UniboExPoc.Project.Party do
      public? true
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
