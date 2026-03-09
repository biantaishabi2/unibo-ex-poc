defmodule UniboExPoc.Project.ProjectTaskStageLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "项目与任务阶段关联桥接"
  end

  postgres do
    table "project_task_stage_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_project_task_stage_link

    queries do
      get :get_project_project_task_stage_link, :read
      list :list_project_project_task_stage_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :project, UniboExPoc.Project.Project do
      public? true
      allow_nil? false
    end
    belongs_to :task_stage, UniboExPoc.Project.TaskStage do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
