defmodule UniboExPoc.Ofbiz.HumanRes.EmploymentApp do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_employment_apps"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_employment_app

    queries do
      get :get_human_res_employment_app, :read
      list :list_human_res_employment_apps, :read
    end

    mutations do
      create :create_human_res_employment_app, :create
      update :update_human_res_employment_app, :update
      destroy :delete_human_res_employment_app, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :application_id, :string, public?: true
    attribute :application_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :empl_position, UniboExPoc.Ofbiz.HumanRes.EmplPosition do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.HumanRes.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :employment_app_source_type, UniboExPoc.Ofbiz.HumanRes.EmploymentAppSourceType do
      public? true
      attribute_type :string
    end
    belongs_to :applying_party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :referred_by_party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :approver_party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :job_requisition, UniboExPoc.Ofbiz.HumanRes.JobRequisition do
      public? true
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
