# Workflow: training_write_flow — Training 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   start --> [*]
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboV4.HR.Training do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_trainings"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :training_name, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:planned, :in_progress, :completed, :cancelled]
      default :planned
      public? true
    end
    attribute :training_type, :atom do
      constraints one_of: [:internal, :external, :online]
      public? true
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date, public?: true
    attribute :score, :decimal, public?: true
    attribute :cost, :decimal, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
    belongs_to :skill, UniboV4.HR.Skill do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:training_name, :training_type, :start_date, :end_date, :cost, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      argument :skill_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:training_name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :start do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :planned do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :planned}))
        end
      end
      # message: "只有计划中的培训可以开始"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:status, :in_progress)
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
    update :complete do
      accept [:score]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:planned, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:planned, :in_progress]}))
        end
      end
      # message: "只有计划中或进行中的培训可以完成"
      change set_attribute(:status, :completed)
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
    update :cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:planned, :in_progress] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:planned, :in_progress]}))
        end
      end
      # message: "只有计划中或进行中的培训可以取消"
      change set_attribute(:status, :cancelled)
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

  validations do
    validate compare(:end_date, greater_than_or_equal_to: :start_date)
  end

end
