defmodule UniboExPoc.Ofbiz.HumanRes.PersonTraining do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_person_trainings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_person_training

    queries do
      get :get_human_res_person_training, :read
      list :list_human_res_person_trainings, :read
    end

    mutations do
      create :create_human_res_person_training, :create
      update :update_human_res_person_training, :update
      destroy :delete_human_res_person_training, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :approval_status, :string, public?: true
    attribute :reason, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :approver_person, UniboExPoc.Ofbiz.HumanRes.Person do
      public? true
      source_attribute :approver_id
      attribute_type :string
    end
    belongs_to :training_class_type, UniboExPoc.Ofbiz.HumanRes.TrainingClassType do
      public? true
      attribute_type :string
    end
    belongs_to :work_effort, UniboExPoc.Ofbiz.HumanRes.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :training_request, UniboExPoc.Ofbiz.HumanRes.TrainingRequest do
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
