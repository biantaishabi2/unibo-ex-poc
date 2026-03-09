# Workflow: milestone_write_flow — 里程碑写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   reach --> [*]
# ```
defmodule UniboExPoc.Project.Milestone do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "里程碑"
  end

  postgres do
    table "project_milestones"
    repo UniboExPoc.Repo
  end

  graphql do
    type :project_milestone

    queries do
      get :get_project_milestone, :read
      list :list_project_milestones, :read
    end

    mutations do
      create :create_project_milestone, :create
      update :reach_project_milestone, :reach
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "里程碑名称"
    end
    attribute :due_date, :date do
      allow_nil? false
      public? true
      description "截止日期"
    end
    attribute :is_reached, :boolean do
      default false
      public? true
      description "是否已达成"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :project, UniboExPoc.Project.Project do
      public? true
      allow_nil? false
    end
    has_many :task_ids, UniboExPoc.Project.Task do
      public? true
      source_attribute :project_id
      destination_attribute :milestone_id
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
      change set_attribute(:id, expr(id))
    end
    update :reach do
      description "标记已达成"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_reached)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_reached, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有未达成里程碑可以标记达成"
      change set_attribute(:is_reached, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
