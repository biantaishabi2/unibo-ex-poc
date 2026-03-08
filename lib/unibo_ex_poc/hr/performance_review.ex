# Workflow: appraisal_cycle_flow — 绩效评估标准推进流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_confirm --> [*]
#   action_done --> [*]
# ```
# Workflow: appraisal_reopen_flow — 绩效评估取消后恢复流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_cancel --> [*]
#   action_back --> [*]
#   action_confirm --> [*]
# ```
defmodule UniboV4.HR.PerformanceReview do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.HR.PerformanceReview.Notifier]

  resource do
    description "绩效评估"
  end

  postgres do
    table "hr_performance_reviews"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_performance_review

    queries do
      get :get_hr_performance_review, :read
      list :list_hr_performance_reviews, :read
    end

    mutations do
      create :create_hr_performance_review, :create
      update :action_confirm_hr_performance_review, :action_confirm
      update :action_done_hr_performance_review, :action_done
      update :action_cancel_hr_performance_review, :action_cancel
      update :action_back_hr_performance_review, :action_back
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :review_period, :string do
      allow_nil? false
      public? true
      description "评估周期，如 \"2026-H1\""
    end
    attribute :status, :atom do
      constraints one_of: [:new, :pending, :done, :cancel]
      default :new
      public? true
      description "Odoo 原生4态: new=新建, pending=进行中, done=已完成, cancel=已取消"
    end
    attribute :overall_rating, :atom do
      constraints one_of: [:outstanding, :exceeds, :meets, :below, :unsatisfactory]
      public? true
      description "综合评级"
    end
    attribute :date_close, :date do
      public? true
      description "评估截止日"
    end
    attribute :final_interview_date, :date do
      public? true
      description "最终面谈日期"
    end
    attribute :note, :string do
      public? true
      description "评估内容"
    end
    attribute :assessment_note, :string do
      public? true
      description "员工自评"
    end
    attribute :manager_note, :string do
      public? true
      description "经理评语"
    end
    attribute :review_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :reviewer, UniboV4.HR.Employee do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:review_period, :date_close, :final_interview_date, :note, :review_date]
      argument :employee_id, :uuid, allow_nil?: false
      argument :reviewer_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :action_confirm do
      description "确认评估，发送邮件通知给 employee 和 reviewer"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :new do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :new}))
        end
      end
      # message: "只有新建状态可以确认"
      change set_attribute(:status, :pending)
      change UniboV4.HR.Changes.PerformanceReview.ActionConfirmCall6
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_done do
      description "完成评估，overall_rating 必须已填写"
      accept [:overall_rating, :manager_note]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有进行中状态可以完成"
      # skipped: validate present :overall_rating (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:status, :done)
      change UniboV4.HR.Changes.PerformanceReview.ActionDoneCall5
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_cancel do
      description "取消评估"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:new, :pending] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:new, :pending]}))
        end
      end
      # message: "只有新建或进行中状态可以取消"
      change set_attribute(:status, :cancel)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_back do
      description "从取消恢复到新建"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :cancel do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :cancel}))
        end
      end
      # message: "只有已取消状态可以恢复"
      change set_attribute(:status, :new)
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
