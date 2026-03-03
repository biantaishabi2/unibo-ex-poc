# Workflow: planning_slot_lifecycle_flow — 排班正常流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   publish --> [*]
# ```
# Workflow: planning_slot_template_flow — 从模板创建排班流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create_from_template
#   create_from_template --> [*]
# ```
defmodule UniboV4.Project.PlanningSlot do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "project_planning_slots"
    repo UniboV4.Repo
  end

  graphql do
    type :project_planning_slot

    queries do
      get :get_project_planning_slot, :read
      list :list_project_planning_slots, :read
    end

    mutations do
      create :create_create_project_planning_slot, :create
      create :create_create_from_template_project_planning_slot, :create_from_template
      update :update_project_planning_slot, :update
      update :publish_project_planning_slot, :publish
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :start_datetime, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :end_datetime, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :allocated_hours, :decimal, public?: true
    attribute :state, :atom do
      constraints one_of: [:draft, :published]
      default :draft
      public? true
    end
    attribute :allow_overlap, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.Project.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :project, UniboV4.Project.Project do
      public? true
    end
    belongs_to :role, UniboV4.Project.PlanningRole do
      public? true
    end
    belongs_to :recurrence, UniboV4.Project.PlanningRecurrence do
      public? true
    end
    belongs_to :template, UniboV4.Project.PlanningSlotTemplate do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:start_datetime, :end_datetime, :allow_overlap]
      argument :employee_id, :uuid, allow_nil?: false
      argument :project_id, :uuid
      argument :role_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate compare(:end_datetime, greater_than: :start_datetime)
      # message: "排班结束时间必须晚于开始时间"
      # TODO: 不支持的 action 内校验规则 no_overlap
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect associate
      # TODO: 不支持的 change effect generate_recurrence
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:start_datetime, :end_datetime, :state, :allow_overlap]
      # skipped: validate compare :end_datetime (incompatible with bulk update atomic path)
      # skipped: validate no_overlap : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect associate
      # TODO: 不支持的 change effect send_notification
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :publish do
      accept []
      # skipped: validate compare :end_datetime (incompatible with bulk update atomic path)
      # skipped: validate no_overlap : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect associate
      # TODO: 不支持的 change effect send_notification
      change set_attribute(:state, :published)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    create :create_from_template do
      accept []
      argument :template_id, :uuid, allow_nil?: false
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate compare(:end_datetime, greater_than: :start_datetime)
      # message: "排班结束时间必须晚于开始时间"
      # TODO: 不支持的 action 内校验规则 no_overlap
      # TODO: 不支持的 change effect compute
      # TODO: 不支持的 change effect associate
      # TODO: 不支持的 change effect generate_recurrence
      # TODO: 不支持的 change effect copy_from_template
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
