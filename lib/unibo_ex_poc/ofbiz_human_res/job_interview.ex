defmodule UniboExPoc.Ofbiz.HumanRes.JobInterview do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_job_interviews"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_job_interview

    queries do
      get :get_human_res_job_interview, :read
      list :list_human_res_job_interviews, :read
    end

    mutations do
      create :create_human_res_job_interview, :create
      update :update_human_res_job_interview, :update
      destroy :delete_human_res_job_interview, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :job_interview_id, :string, public?: true
    attribute :job_interview_result, :string, public?: true
    attribute :job_interview_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :interviewee_party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      source_attribute :job_interviewee_party_id
      attribute_type :string
    end
    belongs_to :interviewer_party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      source_attribute :job_interviewer_party_id
      attribute_type :string
    end
    belongs_to :job_interview_type, UniboExPoc.Ofbiz.HumanRes.JobInterviewType do
      public? true
      attribute_type :string
    end
    belongs_to :job_requisition, UniboExPoc.Ofbiz.HumanRes.JobRequisition do
      public? true
      attribute_type :string
    end
    belongs_to :enumeration, UniboExPoc.Ofbiz.HumanRes.Enumeration do
      public? true
      source_attribute :grade_secured_enum_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
