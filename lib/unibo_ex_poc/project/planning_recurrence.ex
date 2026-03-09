defmodule UniboExPoc.Project.PlanningRecurrence do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "排班周期配置占位实体"
  end

  postgres do
    table "project_planning_recurrences"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_planning_recurrence

    queries do
      get :get_project_planning_recurrence, :read
      list :list_project_planning_recurrences, :read
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
