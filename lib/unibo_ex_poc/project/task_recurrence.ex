defmodule UniboExPoc.Project.TaskRecurrence do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "任务周期规则占位实体（task.recurrence_id 引用）"
  end

  postgres do
    table "project_task_recurrences"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_task_recurrence

    queries do
      get :get_project_task_recurrence, :read
      list :list_project_task_recurrences, :read
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
