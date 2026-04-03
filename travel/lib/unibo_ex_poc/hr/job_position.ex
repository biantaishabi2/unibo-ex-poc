# Workflow: job_position_write_flow — JobPosition 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.JobPosition do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "岗位"
  end

  postgres do
    table "hr_job_positions"
    repo UniboExPoc.Repo
    identity_index_names unique_position_code: "idx_hr_job_positions_unique_position_code"
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
    attribute :job_classification_id, :uuid do
      public? true
      description "职位分类"
    end
    attribute :cost_center_id, :uuid do
      public? true
      description "成本中心引用（OM↔PA 集成，SAP Position→CostCenter 关联）"
    end
    attribute :description, :string, public?: true
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    belongs_to :department, UniboExPoc.HR.Department do
      public? true
    end
    belongs_to :job, UniboExPoc.HR.Job do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Job Position via Create. doc_url: graphql://contract/hr/create_hr_job_position"
      primary? true
      accept [:position_code, :title, :headcount, :description]
      argument :department_id, :uuid
      argument :job_id, :uuid
      argument :job_classification_id, :uuid
      validate present(:position_code)
      validate present(:title)
    end
    update :update do
      description "Update Job Position via Update. doc_url: graphql://contract/hr/update_hr_job_position"
      primary? true
      accept [:title, :headcount, :is_active, :description, :job_classification_id]
      require_atomic? false
    end
  end

  identities do
    identity :unique_position_code, [:position_code]
  end

end
