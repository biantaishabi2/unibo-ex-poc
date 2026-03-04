defmodule UniboV4.Project.TaskStage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "project_task_stages"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
