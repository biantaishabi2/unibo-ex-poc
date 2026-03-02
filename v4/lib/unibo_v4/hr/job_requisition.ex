defmodule UniboV4.HR.JobRequisition do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "job_requisitions"
    repo UniboV4.Repo
  end

  graphql do
    type :job_requisition

    queries do
      get :get_job_requisition, :read
      list :list_job_requisitions, :read
    end

    mutations do
      create :create_job_requisition, :create
      update :open_job_requisition, :open
      update :close_job_requisition, :close
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :requisition_number, :string, allow_nil?: false, public?: true
    attribute :job_title, :string, allow_nil?: false, public?: true
    attribute :headcount, :integer, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :open, :in_progress, :filled, :cancelled]
      default :draft
        public? true
    end
    attribute :priority, :atom do
      constraints one_of: [:low, :medium, :high, :urgent]
      default :medium
        public? true
    end
    attribute :description, :string, public?: true
    attribute :requirements, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :department, UniboV4.HR.Department, public?: true
    has_many :applications, UniboV4.HR.JobApplication
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:requisition_number, :job_title, :headcount, :priority, :description, :requirements]
      argument :department_id, :uuid
      validate present(:requisition_number)
    end
    update :open do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以发布"
      end
      change set_attribute(:status, :open)
    end
    update :close do
      accept []
      validate attribute_in(:status, [:open, :in_progress]) do
        message "只有已发布或进行中状态可以关闭"
      end
      change set_attribute(:status, :filled)
    end
  end

  validations do
    validate compare(:headcount, greater_than: 0)
  end

  identities do
    identity :unique_requisition_number, [:requisition_number]
  end

end
