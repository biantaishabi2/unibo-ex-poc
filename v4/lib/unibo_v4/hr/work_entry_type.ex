# Workflow: work_entry_type_write_flow — WorkEntryType 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.WorkEntryType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_work_entry_types"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :code, :string do
      allow_nil? false
      public? true
    end
    attribute :external_code, :string, public?: true
    attribute :color, :integer, public?: true
    attribute :sequence, :integer do
      default 25
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
    has_many :work_entries, UniboV4.HR.WorkEntry do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :external_code, :color, :sequence]
      validate present(:name)
      validate present(:code)
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
      accept [:name, :external_code, :color, :sequence, :is_active]
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
    identity :unique_work_entry_type_code, [:code]
  end

end
