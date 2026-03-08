defmodule UniboExPoc.Ofbiz.HumanRes.JobInterviewType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_job_interview_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_job_interview_type

    queries do
      get :get_human_res_job_interview_type, :read
      list :list_human_res_job_interview_types, :read
    end

    mutations do
      create :create_human_res_job_interview_type, :create
      update :update_human_res_job_interview_type, :update
      destroy :delete_human_res_job_interview_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :job_interview_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
