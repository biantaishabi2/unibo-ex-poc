defmodule UniboV4.Project.Project do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Project.Project.Notifier]

  postgres do
    table "projects"
    repo UniboV4.Repo
  end

  graphql do
    type :project

    queries do
      get :get_project, :read
      list :list_projects, :read
    end

    mutations do
      create :create_project, :create
      update :update_project, :update
      update :start_project, :start
      update :complete_project, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :project_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:planning, :in_progress, :on_hold, :completed, :cancelled]
      default :planning
    end
    attribute :start_date, :date
    attribute :end_date, :date
    attribute :budget, :decimal
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :tasks, UniboV4.Project.Task
    has_many :milestones, UniboV4.Project.Milestone
    belongs_to :manager, UniboV4.Accounts.User
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:project_code, :name, :start_date, :end_date, :budget, :description]
      validate present(:project_code)
      validate present(:name)
      change relate_actor(:manager)
    end
    update :update do
      primary? true
      accept [:name, :status, :start_date, :end_date, :budget, :description]
    end
    update :start do
      accept []
      validate attribute_equals(:status, :planning) do
        message "只有计划中状态可以启动"
      end
      change set_attribute(:status, :in_progress)
    end
    update :complete do
      accept []
      validate attribute_equals(:status, :in_progress) do
        message "只有进行中状态可以完成"
      end
      change set_attribute(:status, :completed)
    end
  end

  identities do
    identity :unique_project_code, [:project_code]
  end

end
