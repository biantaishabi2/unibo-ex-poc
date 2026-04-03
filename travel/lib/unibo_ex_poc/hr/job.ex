# Workflow: job_write_flow — Job 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.Job do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "职务分类（SAP OM 的 Job/C 对象），是岗位 (JobPosition) 的上层抽象分类"
  end

  postgres do
    table "hr_jobs"
    repo UniboExPoc.Repo
    identity_index_names unique_job_code: "idx_hr_jobs_unique_job_code"
  end

  graphql do
    type :hr_job

    queries do
      get :get_hr_job, :read
      list :list_hr_jobs, :read
    end

    mutations do
      create :create_hr_job, :create
      update :update_hr_job, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
      description "职务编码，全局唯一"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "职务名称（如\"软件工程师\"、\"财务主管\"）"
    end
    attribute :description, :string do
      public? true
      description "职务描述"
    end
    attribute :job_family, :atom do
      constraints one_of: [:engineering, :finance, :hr, :sales, :marketing, :operations, :management, :other]
      public? true
      description "职务族（SAP Job Family 概念）"
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
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
    has_many :positions, UniboExPoc.HR.JobPosition do
      public? true
      destination_attribute :job_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Job via Create. doc_url: graphql://contract/hr/create_hr_job"
      primary? true
      accept [:code, :name, :description, :job_family]
      validate present(:code)
      validate present(:name)
    end
    update :update do
      description "Update Job via Update. doc_url: graphql://contract/hr/update_hr_job"
      primary? true
      accept [:name, :description, :job_family, :is_active]
      # skipped: validate immutable :code (incompatible with bulk update atomic path)
      require_atomic? false
    end
  end

  identities do
    identity :unique_job_code, [:code]
  end

end
