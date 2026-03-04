# Workflow: pay_grade_write_flow — PayGrade 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.PayGrade do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_pay_grades"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :grade_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :min_salary, :decimal, public?: true
    attribute :max_salary, :decimal, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:grade_code, :name, :min_salary, :max_salary, :description]
      validate present(:grade_code)
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :min_salary, :max_salary, :description]
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
    identity :unique_grade_code, [:grade_code]
  end

end
