# Workflow: job_position_write_flow — JobPosition 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.JobPosition do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "岗位"
  end

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
      description "岗位编号"
    end
    attribute :title, :string do
      allow_nil? false
      public? true
      description "岗位名称"
    end
    attribute :headcount, :integer do
      default 1
      public? true
      description "编制人数"
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:title, :headcount, :is_active, :description]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_position_code, [:position_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
