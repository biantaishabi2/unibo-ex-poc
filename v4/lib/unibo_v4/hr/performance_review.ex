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
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.HR.PerformanceReview.Notifier]

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
    end
    attribute :status, :atom do
      constraints one_of: [:new, :pending, :done, :cancel]
      default :new
      public? true
    end
    attribute :overall_rating, :atom do
      constraints one_of: [:outstanding, :exceeds, :meets, :below, :unsatisfactory]
      public? true
    end
    attribute :date_close, :date, public?: true
    attribute :final_interview_date, :date, public?: true
    attribute :note, :string, public?: true
    attribute :assessment_note, :string, public?: true
    attribute :manager_note, :string, public?: true
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
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :action_confirm do
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
      # TODO: 不支持的 change effect custom
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
    update :action_done do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :done)
      # TODO: 不支持的 change effect custom
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
    update :action_cancel do
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
    update :action_back do
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
  end

end
