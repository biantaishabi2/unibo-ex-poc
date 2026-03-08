defmodule UniboV4.Ofbiz.HumanRes.JobRequisition do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_job_requisitions"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_job_requisition

    queries do
      get :get_human_res_job_requisition, :read
      list :list_human_res_job_requisitions, :read
    end

    mutations do
      create :create_human_res_job_requisition, :create
      update :update_human_res_job_requisition, :update
      destroy :delete_human_res_job_requisition, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :job_requisition_id, :string, public?: true
    attribute :duration_months, :integer, public?: true
    attribute :age, :integer, public?: true
    attribute :gender, :boolean, public?: true
    attribute :experience_months, :integer, public?: true
    attribute :experience_years, :integer, public?: true
    attribute :qualification, :string, public?: true
    attribute :job_location, :string, public?: true
    attribute :no_of_resources, :integer, public?: true
    attribute :job_requisition_date, :utc_datetime, public?: true
    attribute :required_on_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :skill_type, UniboV4.Ofbiz.HumanRes.SkillType do
      public? true
      attribute_type :string
    end
    belongs_to :exam_type_enumeration, UniboV4.Ofbiz.HumanRes.Enumeration do
      public? true
      source_attribute :exam_type_enum_id
      attribute_type :string
    end
    belongs_to :job_posting_type_enumeration, UniboV4.Ofbiz.HumanRes.Enumeration do
      public? true
      source_attribute :job_posting_type_enum_id
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
