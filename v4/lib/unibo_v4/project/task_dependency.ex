defmodule UniboV4.Project.TaskDependency do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "task_dependencies"
    repo UniboV4.Repo
  end

  graphql do
    type :task_dependency

    queries do
      get :get_task_dependency, :read
      list :list_task_dependencys, :read
    end

    mutations do
      create :create_task_dependency, :create
      destroy :delete_task_dependency, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :dependency_type, :atom do
      constraints one_of: [:finish_to_start, :start_to_start, :finish_to_finish]
      default :finish_to_start
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :task, UniboV4.Project.Task do
      allow_nil? false
    end
    belongs_to :depends_on, UniboV4.Project.Task do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:dependency_type]
      argument :task_id, :uuid, allow_nil?: false
      argument :depends_on_id, :uuid, allow_nil?: false
      change manage_relationship(:task_id, :task, type: :append, on_lookup: :relate)
      change manage_relationship(:depends_on_id, :depends_on, type: :append, on_lookup: :relate)
    end
  end

end
