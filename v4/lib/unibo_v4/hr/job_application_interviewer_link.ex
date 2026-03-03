defmodule UniboV4.HR.JobApplicationInterviewerLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "hr_job_application_interviewer_links"
    repo UniboV4.Repo
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
    belongs_to :job_application, UniboV4.HR.JobApplication do
      public? true
      allow_nil? false
    end
    belongs_to :employee, UniboV4.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
