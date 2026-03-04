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
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Project.Timesheet.Notifier]

  postgres do
    table "project_timesheets"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :period, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :submitted, :approved, :rejected]
      default :draft
      public? true
    end
    attribute :total_hours, :decimal, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :entries, UniboV4.Project.TimesheetEntry do
      public? true
    end
    belongs_to :employee, UniboV4.Project.User do
      public? true
      allow_nil? false
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
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :submit do
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
    update :approve do
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
    update :reject do
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
