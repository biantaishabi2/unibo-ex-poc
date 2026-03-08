defmodule UniboExPoc.Project.PlanningRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "排班角色占位实体"
  end

  postgres do
    table "project_planning_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_planning_role

    queries do
      get :get_project_planning_role, :read
      list :list_project_planning_roles, :read
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
