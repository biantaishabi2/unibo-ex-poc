# Workflow: resume_line_write_flow — ResumeLine 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.ResumeLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "hr_resume_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_resume_line

    queries do
      get :get_hr_resume_line, :read
      list :list_hr_resume_lines, :read
    end

    mutations do
      create :create_hr_resume_line, :create
      update :update_hr_resume_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :date_start, :date do
      allow_nil? false
      public? true
    end
    attribute :date_end, :date, public?: true
    attribute :description, :string, public?: true
    attribute :display_type, :atom do
      constraints one_of: [:classic]
      default :classic
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
    belongs_to :line_type, UniboV4.HR.ResumeLineType do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :date_start, :date_end, :description, :display_type]
      argument :employee_id, :uuid, allow_nil?: false
      argument :line_type_id, :uuid
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:date_start)
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
      accept [:name, :date_start, :date_end, :description]
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
