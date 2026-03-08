defmodule UniboExPoc.HR.JobApplicationInterviewerLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "申请与面试官关联桥接"
  end

  postgres do
    table "hr_job_application_interviewer_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_job_application_interviewer_link

    queries do
      get :get_hr_job_application_interviewer_link, :read
      list :list_hr_job_application_interviewer_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :job_application, UniboExPoc.HR.JobApplication do
      public? true
      allow_nil? false
    end
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
