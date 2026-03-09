defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortContactMech do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_work_effort_contact_meches"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_contact_mech

    queries do
      get :get_work_effort_work_effort_contact_mech, :read
      list :list_work_effort_work_effort_contact_mechs, :read
    end

    mutations do
      create :create_work_effort_work_effort_contact_mech, :create
      update :update_work_effort_work_effort_contact_mech, :update
      destroy :delete_work_effort_work_effort_contact_mech, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :contact_mech, UniboExPoc.Ofbiz.WorkEffort.ContactMech do
      public? true
      attribute_type :string
    end
    belongs_to :telecom_number, UniboExPoc.Ofbiz.WorkEffort.TelecomNumber do
      public? true
      source_attribute :contact_mech_id
      define_attribute? false
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
