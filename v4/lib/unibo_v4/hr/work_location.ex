# Workflow: work_location_write_flow — WorkLocation 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.WorkLocation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_work_locations"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :location_type, :atom do
      allow_nil? false
      constraints one_of: [:home, :office, :other]
      public? true
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :employee_locations, UniboV4.HR.EmployeeLocation do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :location_type]
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
      accept [:name, :location_type, :is_active]
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
