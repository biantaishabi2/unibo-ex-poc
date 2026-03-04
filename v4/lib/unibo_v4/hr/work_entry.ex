# Workflow: work_entry_validation_flow — 工时条目校验流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_validate --> [*]
# ```
# Workflow: work_entry_cancel_flow — 工时条目取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   action_cancel --> [*]
# ```
defmodule UniboV4.HR.WorkEntry do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.HR.WorkEntry.Notifier]

  postgres do
    table "hr_work_entries"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :date_start, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :date_stop, :utc_datetime, public?: true
    attribute :duration, :decimal, public?: true
    attribute :state, :atom do
      constraints one_of: [:draft, :validated, :conflict, :cancelled]
      default :draft
      public? true
    end
    attribute :conflict, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :work_entry_type, UniboV4.HR.WorkEntryType do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :date_start, :date_stop, :duration]
      argument :employee_id, :uuid, allow_nil?: false
      argument :work_entry_type_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:date_start)
      # TODO: 不支持的 change effect custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :action_validate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以验证"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:state, :validated)
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
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :conflict] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :conflict]}))
        end
      end
      # message: "只有草稿或冲突状态可以取消"
      change set_attribute(:state, :cancelled)
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
