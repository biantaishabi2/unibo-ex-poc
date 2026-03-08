defmodule UniboV4.Project.ProjectStage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "项目阶段占位实体（project.stage_id 引用）"
  end

  postgres do
    table "project_stages"
    repo UniboV4.Repo
  end

  graphql do
    type :project_project_stage

    queries do
      get :get_project_project_stage, :read
      list :list_project_project_stages, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :sequence, :integer, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
