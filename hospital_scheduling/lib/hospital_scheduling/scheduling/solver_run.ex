# Workflow: solver_run_lifecycle — 求解运行生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> start_run
#   start_run --> complete_feasible
#   start_run --> complete_infeasible
#   start_run --> mark_timeout
#   start_run --> mark_error
#   complete_feasible --> mark_completed
#   mark_timeout --> mark_completed
# ```
defmodule HospitalScheduling.Scheduling.SolverRun do
  use Ash.Resource,
    otp_app: :hospital_scheduling,
    domain: HospitalScheduling.Scheduling,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "一次求解执行记录与输入/输出快照载体"
  end

  postgres do
    table "scheduling_solver_runs"
    repo HospitalScheduling.Repo
  end

  graphql do
    type :scheduling_solver_run

    queries do
      get :get_scheduling_solver_run, :read
      list :list_scheduling_solver_runs, :read
    end

    mutations do
      create :create_scheduling_solver_run, :create
      update :update_scheduling_solver_run, :update
      update :start_run_scheduling_solver_run, :start_run
      update :complete_feasible_scheduling_solver_run, :complete_feasible
      update :complete_infeasible_scheduling_solver_run, :complete_infeasible
      update :mark_timeout_scheduling_solver_run, :mark_timeout
      update :mark_error_scheduling_solver_run, :mark_error
      update :mark_completed_scheduling_solver_run, :mark_completed
      destroy :delete_scheduling_solver_run, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :running, :feasible, :infeasible, :timeout, :error, :completed]
      default :pending
      public? true
      description "求解状态"
    end
    attribute :engine_type, :string do
      allow_nil? false
      default "cp_sat"
      public? true
      description "算法标识"
    end
    attribute :seed, :integer do
      public? true
      description "随机种子，用于复现实验"
    end
    attribute :timeout_ms, :integer do
      allow_nil? false
      default 30000
      public? true
      description "超时毫秒数"
    end
    attribute :started_at, :utc_datetime do
      public? true
      description "求解开始时间"
    end
    attribute :completed_at, :utc_datetime do
      public? true
      description "求解结束时间"
    end
    attribute :score, :decimal do
      public? true
      description "总评分"
    end
    attribute :hard_violation_count, :integer do
      allow_nil? false
      default 0
      public? true
      description "硬约束违反数"
    end
    attribute :warning_count, :integer do
      allow_nil? false
      default 0
      public? true
      description "警告数"
    end
    attribute :input_snapshot, :map do
      allow_nil? false
      public? true
      description "输入快照（跨域数据在 run 开始时一次性冻结）"
    end
    attribute :output_snapshot, :map do
      public? true
      description "输出摘要（不重复整份 assignment 明细）"
    end
    attribute :error_message, :string do
      public? true
      description "错误信息"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :period, HospitalScheduling.Scheduling.SchedulingPeriod do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Solver Run via Create. doc_url: graphql://contract/scheduling/create_scheduling_solver_run"
      primary? true
      accept [:engine_type, :seed, :timeout_ms, :input_snapshot]
      argument :period_id, :uuid, allow_nil?: false
      change manage_relationship(:period_id, :period, type: :append, on_lookup: :relate)
    end
    update :update do
      description "Update Solver Run via Update. doc_url: graphql://contract/scheduling/update_scheduling_solver_run"
      primary? true
      accept [:status, :started_at, :completed_at, :score, :hard_violation_count, :warning_count, :output_snapshot, :error_message]
      require_atomic? false
    end
    update :start_run do
      description "标记求解开始

标记求解开始. doc_url: graphql://contract/scheduling/start_run_scheduling_solver_run"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待执行状态可以开始"
      change set_attribute(:status, :running)
      change HospitalScheduling.Scheduling.Integrations.SolverRun.StartRunRustSolverInvokeBridge
      change transition_state(:running)
      require_atomic? false
    end
    update :complete_feasible do
      description "求解完成（可行解）

求解完成（可行解）. doc_url: graphql://contract/scheduling/complete_feasible_scheduling_solver_run"
      accept [:score, :hard_violation_count, :warning_count, :output_snapshot]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有运行中状态可以完成"
      change set_attribute(:status, :feasible)
      change transition_state(:feasible)
      require_atomic? false
    end
    update :complete_infeasible do
      description "求解完成（不可行）

求解完成（不可行）. doc_url: graphql://contract/scheduling/complete_infeasible_scheduling_solver_run"
      accept [:score, :hard_violation_count, :warning_count, :output_snapshot, :error_message]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有运行中状态可以完成"
      change set_attribute(:status, :infeasible)
      change transition_state(:infeasible)
      require_atomic? false
    end
    update :mark_timeout do
      description "求解超时

求解超时. doc_url: graphql://contract/scheduling/mark_timeout_scheduling_solver_run"
      accept [:score, :hard_violation_count, :warning_count, :output_snapshot]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有运行中状态可以完成"
      change set_attribute(:status, :timeout)
      change transition_state(:timeout)
      require_atomic? false
    end
    update :mark_error do
      description "求解出错

求解出错. doc_url: graphql://contract/scheduling/mark_error_scheduling_solver_run"
      accept [:error_message]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有运行中状态可以完成"
      change set_attribute(:status, :error)
      change transition_state(:error)
      require_atomic? false
    end
    update :mark_completed do
      description "最终完成（用户确认采用此结果）

最终完成（用户确认采用此结果）. doc_url: graphql://contract/scheduling/mark_completed_scheduling_solver_run"
      accept []
      change set_attribute(:status, :completed)
      change transition_state(:completed)
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, HospitalScheduling.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end


  state_machine do
    initial_states [:pending]
    default_initial_state :pending
    state_attribute :status
    transitions do
      transition :start_run, from: :pending, to: :running
      transition :complete_feasible, from: :running, to: :feasible
      transition :complete_infeasible, from: :running, to: :infeasible
      transition :mark_timeout, from: :running, to: :timeout
      transition :mark_error, from: :running, to: :error
      transition :mark_completed, from: :feasible, to: :completed
    end
  end

  pub_sub do
    module HospitalScheduling.PubSub
    prefix "solver_run"

    publish :start_run, ["scheduling.solver.started"]
    publish :complete_feasible, ["scheduling.solver.completed"]
    publish :complete_infeasible, ["scheduling.solver.infeasible"]
    publish :mark_error, ["scheduling.solver.errored"]
    publish :mark_timeout, ["scheduling.solver.timed_out"]
  end
end
