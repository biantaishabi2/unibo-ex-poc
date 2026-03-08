defmodule UniboExPoc.Project.TaskStage do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "任务阶段占位实体"
  end

  postgres do
    table "project_task_stages"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_task_stage

    queries do
      get :get_project_task_stage, :read
      list :list_project_task_stages, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :sequence, :integer, public?: true
    attribute :fold, :boolean do
      default false
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
