defmodule UniboV4.Project.Milestone do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "milestones"
    repo UniboV4.Repo
  end

  graphql do
    type :milestone

    queries do
      get :get_milestone, :read
      list :list_milestones, :read
    end

    mutations do
      create :create_milestone, :create
      update :reach_milestone, :reach
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :due_date, :date, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:pending, :reached, :missed]
      default :pending
    end
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :project, UniboV4.Project.Project do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :due_date, :description]
      argument :project_id, :uuid, allow_nil?: false
      change manage_relationship(:project_id, :project, type: :append, on_lookup: :relate)
      validate present(:name)
    end
    update :reach do
      accept []
      validate attribute_equals(:status, :pending) do
        message "只有待处理里程碑可以标记达成"
      end
      change set_attribute(:status, :reached)
    end
  end

end
