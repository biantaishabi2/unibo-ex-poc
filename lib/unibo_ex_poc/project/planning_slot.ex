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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "排班时段"
  end

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
      description "排班开始时间"
    end
    attribute :end_datetime, :utc_datetime do
      allow_nil? false
      public? true
      description "排班结束时间"
    end
    attribute :allocated_hours, :decimal do
      public? true
      description "基于 start/end 和员工工作日历自动计算的工时"
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :published]
      default :draft
      public? true
      description "排班状态"
    end
    attribute :allow_overlap, :boolean do
      default false
      public? true
      description "是否允许时段重叠"
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
      validate {UniboV4.Project.Validations.PlanningSlot.NoOverlap, []}
      # message: "同一员工在同一时段不能有重叠排班"
      change UniboV4.Project.Changes.PlanningSlot.ComputeAllocatedHours
      change UniboV4.Project.Changes.PlanningSlot.CreateCall2
      change UniboV4.Project.Changes.PlanningSlot.CreateCall4
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:start_datetime, :end_datetime, :state, :allow_overlap, :project_id, :role_id]
      # skipped: validate compare :end_datetime (incompatible with bulk update atomic path)
      # skipped: validate no_overlap : (incompatible with bulk update atomic path)
      change UniboV4.Project.Changes.PlanningSlot.ComputeAllocatedHours
      change UniboV4.Project.Changes.PlanningSlot.UpdateCall2
      change UniboV4.Project.Changes.PlanningSlot.UpdateCall3
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "发布排班"
      accept []
      # skipped: validate compare :end_datetime (incompatible with bulk update atomic path)
      # skipped: validate no_overlap : (incompatible with bulk update atomic path)
      change UniboV4.Project.Changes.PlanningSlot.ComputeAllocatedHours
      change UniboV4.Project.Changes.PlanningSlot.PublishCall2
      change UniboV4.Project.Changes.PlanningSlot.PublishCall3
      change set_attribute(:state, :published)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    create :create_from_template do
      description "从模板快速创建排班"
      accept []
      argument :template_id, :uuid, allow_nil?: false
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate compare(:end_datetime, greater_than: :start_datetime)
      # message: "排班结束时间必须晚于开始时间"
      validate {UniboV4.Project.Validations.PlanningSlot.NoOverlap, []}
      # message: "同一员工在同一时段不能有重叠排班"
      change UniboV4.Project.Changes.PlanningSlot.ComputeAllocatedHours
      change UniboV4.Project.Changes.PlanningSlot.CreateFromTemplateCall2
      change UniboV4.Project.Changes.PlanningSlot.CreateFromTemplateCall4
      change UniboV4.Project.Changes.PlanningSlot.CreateFromTemplateCall5
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
