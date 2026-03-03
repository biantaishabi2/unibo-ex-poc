# Workflow: job_position_write_flow — JobPosition 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.JobPosition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "hr_job_positions"
    repo UniboV4.Repo
  end

  graphql do
    type :hr_job_position

    queries do
      get :get_hr_job_position, :read
      list :list_hr_job_positions, :read
    end

    mutations do
      create :create_hr_job_position, :create
      update :update_hr_job_position, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :position_code, :string do
      allow_nil? false
      public? true
    end
    attribute :title, :string do
      allow_nil? false
      public? true
    end
    attribute :headcount, :integer do
      default 1
      public? true
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboV4.HR.Department do
      public? true
    end
    belongs_to :pay_grade, UniboV4.HR.PayGrade do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:position_code, :title, :headcount, :description]
      argument :department_id, :uuid
      validate present(:position_code)
      validate present(:title)
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
      accept [:title, :headcount, :is_active, :description]
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
    identity :unique_position_code, [:position_code]
  end

end
