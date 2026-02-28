defmodule UniboV4.Project.TaskAssignment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "task_assignments"
    repo UniboV4.Repo
  end

  graphql do
    type :task_assignment

    queries do
      get :get_task_assignment, :read
      list :list_task_assignments, :read
    end

    mutations do
      create :create_task_assignment, :create
      destroy :delete_task_assignment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string
    attribute :from_date, :date, allow_nil?: false
    attribute :thru_date, :date
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :task, UniboV4.Project.Task do
      allow_nil? false
    end
    belongs_to :assignee, UniboV4.Accounts.User do
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:role, :from_date, :thru_date]
      argument :task_id, :uuid, allow_nil?: false
      argument :assignee_id, :uuid, allow_nil?: false
      change manage_relationship(:task_id, :task, type: :append, on_lookup: :relate)
      change manage_relationship(:assignee_id, :assignee, type: :append, on_lookup: :relate)
    end
  end

end
