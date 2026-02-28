defmodule UniboV4.Project.Task do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Project.Task.Notifier]

  postgres do
    table "tasks"
    repo UniboV4.Repo
  end

  graphql do
    type :task

    queries do
      get :get_task, :read
      list :list_tasks, :read
    end

    mutations do
      create :create_task, :create
      update :update_task, :update
      update :start_task, :start
      update :complete_task, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:todo, :in_progress, :review, :done, :cancelled]
      default :todo
    end
    attribute :priority, :atom do
      constraints one_of: [:low, :medium, :high, :urgent]
      default :medium
    end
    attribute :start_date, :date
    attribute :due_date, :date
    attribute :estimated_hours, :decimal
    attribute :actual_hours, :decimal
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :project, UniboV4.Project.Project do
      allow_nil? false
    end
    has_many :assignments, UniboV4.Project.TaskAssignment
    has_many :dependencies, UniboV4.Project.TaskDependency
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :priority, :start_date, :due_date, :estimated_hours, :description]
      argument :project_id, :uuid, allow_nil?: false
      change manage_relationship(:project_id, :project, type: :append, on_lookup: :relate)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :status, :priority, :start_date, :due_date, :estimated_hours, :actual_hours, :description]
    end
    update :start do
      accept []
      validate attribute_equals(:status, :todo) do
        message "只有待办状态可以开始"
      end
      change set_attribute(:status, :in_progress)
    end
    update :complete do
      accept [:actual_hours]
      validate attribute_in(:status, [:in_progress, :review]) do
        message "只有进行中或评审状态可以完成"
      end
      change set_attribute(:status, :done)
    end
  end

end
