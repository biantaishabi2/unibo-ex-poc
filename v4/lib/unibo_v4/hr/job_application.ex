defmodule UniboV4.HR.JobApplication do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.HR.JobApplication.Notifier]

  postgres do
    table "job_applications"
    repo UniboV4.Repo
  end

  graphql do
    type :job_application

    queries do
      get :get_job_application, :read
      list :list_job_applications, :read
    end

    mutations do
      create :create_job_application, :create
      update :advance_job_application, :advance
      update :reject_job_application, :reject
      update :hire_job_application, :hire
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :applicant_name, :string, allow_nil?: false, public?: true
    attribute :email, :string, public?: true
    attribute :phone, :string, public?: true
    attribute :status, :atom do
      constraints one_of: [:received, :screening, :interview, :offer, :hired, :rejected]
      default :received
        public? true
    end
    attribute :resume_summary, :string, public?: true
    attribute :notes, :string, public?: true
    attribute :applied_date, :date, allow_nil?: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :requisition, UniboV4.HR.JobRequisition do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:applicant_name, :email, :phone, :resume_summary, :notes, :applied_date]
      argument :requisition_id, :uuid, allow_nil?: false
      change manage_relationship(:requisition_id, :requisition, type: :append, on_lookup: :relate)
      validate present(:applicant_name)
    end
    update :advance do
      accept [:status]
    end
    update :reject do
      accept [:notes]
      validate attribute_in(:status, [:received, :screening, :interview, :offer]) do
        message "已录用或已拒绝的申请不能再拒绝"
      end
      change set_attribute(:status, :rejected)
    end
    update :hire do
      accept []
      change set_attribute(:status, :hired)
    end
  end

end
