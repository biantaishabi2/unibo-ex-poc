# Workflow: timesheet_approve_flow — 工时表审批通过流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   approve --> [*]
# ```
# Workflow: timesheet_reject_flow — 工时表驳回流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   reject --> [*]
# ```
defmodule UniboV4.Project.Timesheet do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Project.Timesheet.Notifier]

  resource do
    description "工时表（按 Task 维度聚合的逻辑视图）"
  end

  postgres do
    table "project_timesheets"
    repo UniboV4.Repo
  end

  graphql do
    type :project_timesheet

    queries do
      get :get_project_timesheet, :read
      list :list_project_timesheets, :read
    end

    mutations do
      create :create_project_timesheet, :create
      update :submit_project_timesheet, :submit
      update :approve_project_timesheet, :approve
      update :reject_project_timesheet, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :period, :string do
      allow_nil? false
      public? true
      description "工时周期（如 2026-W09）"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected]
      default :draft
      public? true
    end
    attribute :total_hours, :decimal do
      public? true
      description "总工时"
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :entries, UniboV4.Project.TimesheetEntry do
      public? true
    end
    belongs_to :employee, UniboV4.Project.Party do
      public? true
      allow_nil? false
      source_attribute :employee_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:period, :notes]
      argument :entries, {:array, :string}
      change manage_relationship(:entries, :entries, type: :create)
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      change relate_actor(:employee)
      change UniboV4.Project.Changes.Timesheet.ComputeTotalHours
      change set_attribute(:id, expr(id))
    end
    update :submit do
      description "提交审批"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以提交"
      change set_attribute(:status, :submitted)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :approve do
      description "审批通过"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以审批"
      change set_attribute(:status, :approved)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reject do
      description "审批驳回"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有已提交状态可以驳回"
      change set_attribute(:status, :rejected)
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
