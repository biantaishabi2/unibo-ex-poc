# Workflow: employment_contract_write_flow — EmploymentContract 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   activate --> [*]
#   terminate --> [*]
# ```
defmodule UniboV4.HR.EmploymentContract do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_employment_contracts"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :contract_number, :string do
      allow_nil? false
      public? true
    end
    attribute :contract_type, :atom do
      allow_nil? false
      constraints one_of: [:fixed_term, :permanent, :probation, :internship]
      public? true
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date, public?: true
    attribute :salary, :decimal, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :expired, :terminated]
      default :draft
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:contract_number, :contract_type, :start_date, :end_date, :salary, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:contract_number)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :activate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以激活"
      change set_attribute(:status, :active)
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
    update :terminate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有激活状态可以终止"
      change set_attribute(:status, :terminated)
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

  identities do
    identity :unique_contract_number, [:contract_number]
  end

end
