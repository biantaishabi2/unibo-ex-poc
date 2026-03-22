# Workflow: scheduling_period_lifecycle — 排班周期生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> start_generating
#   create --> update
#   create --> destroy
#   start_generating --> mark_generated
#   mark_generated --> mark_adjusted
#   mark_generated --> publish
#   mark_generated --> start_generating
#   mark_adjusted --> publish
#   mark_adjusted --> start_generating
#   publish --> start_generating
# ```
defmodule UniboExPoc.Scheduling.SchedulingPeriod do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "一次科室月排班工作空间，承载需求、版本、求解运行"
  end

  postgres do
    table "scheduling_periods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :scheduling_scheduling_period

    queries do
      get :get_scheduling_scheduling_period, :read
      list :list_scheduling_scheduling_periods, :read
    end

    mutations do
      create :create_scheduling_scheduling_period, :create
      update :update_scheduling_scheduling_period, :update
      update :start_generating_scheduling_scheduling_period, :start_generating
      update :mark_generated_scheduling_scheduling_period, :mark_generated
      update :mark_adjusted_scheduling_scheduling_period, :mark_adjusted
      update :publish_scheduling_scheduling_period, :publish
      destroy :delete_scheduling_scheduling_period, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :start_date, :date do
      allow_nil? false
      public? true
      description "周期开始日期（本地业务日）"
    end
    attribute :end_date, :date do
      allow_nil? false
      public? true
      description "周期结束日期（本地业务日）"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :generating, :generated, :adjusted, :published]
      default :draft
      public? true
      description "排班周期状态"
    end
    attribute :title, :string do
      public? true
      description "例如\"ICU 2026-04 月排班\""
    end
    attribute :generation_mode, :atom do
      allow_nil? false
      constraints one_of: [:blank, :cloned_from_previous, :solver_seeded]
      default :blank
      public? true
      description "排班生成方式"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboExPoc.Scheduling.Department do
      public? true
      allow_nil? false
    end
    belongs_to :source_period, UniboExPoc.Scheduling.SchedulingPeriod do
      public? true
    end
    belongs_to :source_version, UniboExPoc.Scheduling.ScheduleVersion do
      public? true
    end
    belongs_to :current_version, UniboExPoc.Scheduling.ScheduleVersion do
      public? true
    end
    belongs_to :published_version, UniboExPoc.Scheduling.ScheduleVersion do
      public? true
    end
    belongs_to :last_solver_run, UniboExPoc.Scheduling.SolverRun do
      public? true
    end
    has_many :coverage_requirements, UniboExPoc.Scheduling.CoverageRequirement do
      public? true
      destination_attribute :period_id
    end
    has_many :schedule_versions, UniboExPoc.Scheduling.ScheduleVersion do
      public? true
      destination_attribute :period_id
    end
    has_many :solver_runs, UniboExPoc.Scheduling.SolverRun do
      public? true
      destination_attribute :period_id
    end
    has_many :shift_assignments, UniboExPoc.Scheduling.ShiftAssignment do
      public? true
      destination_attribute :period_id
    end
    has_many :constraint_violations, UniboExPoc.Scheduling.ConstraintViolation do
      public? true
      destination_attribute :period_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Scheduling Period via Create. doc_url: graphql://contract/scheduling/create_scheduling_scheduling_period"
      primary? true
      accept [:start_date, :end_date, :title, :notes, :generation_mode]
      argument :department_id, :uuid, allow_nil?: false
      change manage_relationship(:department_id, :department, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Scheduling Period via Update. doc_url: graphql://contract/scheduling/update_scheduling_scheduling_period"
      primary? true
      accept [:title, :notes]
      require_atomic? false
    end
    update :start_generating do
      description "开始自动生成排班

开始自动生成排班. doc_url: graphql://contract/scheduling/start_generating_scheduling_scheduling_period"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以开始生成"
      change set_attribute(:state, :generating)
      require_atomic? false
    end
    update :mark_generated do
      description "求解完成，标记为已生成

求解完成，标记为已生成. doc_url: graphql://contract/scheduling/mark_generated_scheduling_scheduling_period"
      accept []
      change set_attribute(:state, :generated)
      require_atomic? false
    end
    update :mark_adjusted do
      description "人工调班后标记

人工调班后标记. doc_url: graphql://contract/scheduling/mark_adjusted_scheduling_scheduling_period"
      accept []
      change set_attribute(:state, :adjusted)
      require_atomic? false
    end
    update :publish do
      description "发布排班（需无 error 级违反）

发布排班（需无 error 级违反）. doc_url: graphql://contract/scheduling/publish_scheduling_scheduling_period"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:generated, :adjusted] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:generated, :adjusted]}))
        end
      end
      # message: "只有已生成或已调整状态可以发布"
      change set_attribute(:state, :published)
      require_atomic? false
    end
  end

  validations do
    validate compare(:end_date, greater_than: :start_date)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
