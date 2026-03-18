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
defmodule HospitalScheduling.Scheduling.SchedulingPeriod do
  use Ash.Resource,
    otp_app: :hospital_scheduling,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "一次科室月排班工作空间，承载需求、版本、求解运行"
  end

  postgres do
    table "scheduling_periods"
    repo HospitalScheduling.Repo
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :department, HospitalScheduling.Scheduling.Department do
      public? true
      allow_nil? false
    end
    belongs_to :source_period, HospitalScheduling.Scheduling.SchedulingPeriod do
      public? true
    end
    belongs_to :source_version, HospitalScheduling.Scheduling.ScheduleVersion do
      public? true
    end
    belongs_to :current_version, HospitalScheduling.Scheduling.ScheduleVersion do
      public? true
    end
    belongs_to :published_version, HospitalScheduling.Scheduling.ScheduleVersion do
      public? true
    end
    belongs_to :last_solver_run, HospitalScheduling.Scheduling.SolverRun do
      public? true
    end
    has_many :coverage_requirements, HospitalScheduling.Scheduling.CoverageRequirement do
      public? true
      destination_attribute :period_id
    end
    has_many :schedule_versions, HospitalScheduling.Scheduling.ScheduleVersion do
      public? true
      destination_attribute :period_id
    end
    has_many :solver_runs, HospitalScheduling.Scheduling.SolverRun do
      public? true
      destination_attribute :period_id
    end
    has_many :shift_assignments, HospitalScheduling.Scheduling.ShiftAssignment do
      public? true
      destination_attribute :period_id
    end
    has_many :constraint_violations, HospitalScheduling.Scheduling.ConstraintViolation do
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
      change HospitalScheduling.Scheduling.Changes.SchedulingPeriod.StartGeneratingCall1
      change set_attribute(:state, :generating)
      change transition_state(:generating)
      require_atomic? false
    end
    update :mark_generated do
      description "求解完成，标记为已生成

求解完成，标记为已生成. doc_url: graphql://contract/scheduling/mark_generated_scheduling_scheduling_period"
      accept []
      change set_attribute(:state, :generated)
      change transition_state(:generated)
      require_atomic? false
    end
    update :mark_adjusted do
      description "人工调班后标记

人工调班后标记. doc_url: graphql://contract/scheduling/mark_adjusted_scheduling_scheduling_period"
      accept []
      change set_attribute(:state, :adjusted)
      change transition_state(:adjusted)
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
      change HospitalScheduling.Scheduling.Changes.SchedulingPeriod.PublishCall1
      change set_attribute(:state, :published)
      change transition_state(:published)
      require_atomic? false
    end

    update :on_solver_run_complete_feasible do
      accept []
      # determination semantics: phase=save, scope=cross_aggregate, mode=async_write_back
      # 异步写回：通过 AsyncRuntime.Queue 进入 outbox 风格队列
      change fn changeset, _ctx ->
        queue_module = HospitalScheduling.AsyncRuntime.Queue
        record_id = changeset.data && changeset.data.id
        dedup_key = "determination:scheduling_period:on_solver_run_complete_feasible:#{inspect(record_id)}"
        payload = %{
          "entity" => "scheduling_period",
          "determination" => "on_solver_run_complete_feasible",
          "scope" => "cross_aggregate",
          "mode" => "async_write_back",
          "record_id" => record_id
        }
        if Code.ensure_loaded?(queue_module) and function_exported?(queue_module, :enqueue, 1) do
          case queue_module.enqueue(%{kind: "determination_async_write_back", dedup_key: dedup_key, payload: payload}) do
            {:ok, _task} -> changeset
            {:ok, :duplicate} -> changeset
            {:error, reason} -> Ash.Changeset.add_error(changeset, "async determination enqueue failed: #{inspect(reason)}")
          end
        else
          Ash.Changeset.add_error(changeset, "async runtime queue unavailable")
        end
      end
      require_atomic? false
    end

    update :on_schedule_version_publish do
      accept []
      # determination semantics: phase=save, scope=cross_aggregate, mode=async_write_back
      # 异步写回：通过 AsyncRuntime.Queue 进入 outbox 风格队列
      change fn changeset, _ctx ->
        queue_module = HospitalScheduling.AsyncRuntime.Queue
        record_id = changeset.data && changeset.data.id
        dedup_key = "determination:scheduling_period:on_schedule_version_publish:#{inspect(record_id)}"
        payload = %{
          "entity" => "scheduling_period",
          "determination" => "on_schedule_version_publish",
          "scope" => "cross_aggregate",
          "mode" => "async_write_back",
          "record_id" => record_id
        }
        if Code.ensure_loaded?(queue_module) and function_exported?(queue_module, :enqueue, 1) do
          case queue_module.enqueue(%{kind: "determination_async_write_back", dedup_key: dedup_key, payload: payload}) do
            {:ok, _task} -> changeset
            {:ok, :duplicate} -> changeset
            {:error, reason} -> Ash.Changeset.add_error(changeset, "async determination enqueue failed: #{inspect(reason)}")
          end
        else
          Ash.Changeset.add_error(changeset, "async runtime queue unavailable")
        end
      end
      require_atomic? false
    end
  end

  validations do
    validate compare(:end_date, greater_than: :start_date)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, HospitalScheduling.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:coverage_requirements, :schedule_versions, :solver_runs, :shift_assignments, :constraint_violations]
  end


  state_machine do
    initial_states [:draft]
    default_initial_state :draft
    state_attribute :state
    transitions do
      transition :start_generating, from: :draft, to: :generating
      transition :mark_generated, from: :generating, to: :generated
      transition :mark_adjusted, from: :generated, to: :adjusted
      transition :publish, from: :adjusted, to: :published
      transition :publish, from: :generated, to: :published
    end
  end

  pub_sub do
    module HospitalScheduling.PubSub
    prefix "scheduling_period"

    publish :create, ["scheduling.period.created"]
    publish :mark_generated, ["scheduling.period.generated"]
    publish :mark_adjusted, ["scheduling.period.adjusted"]
  end
end
