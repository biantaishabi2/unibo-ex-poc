defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortPartyAssignment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_party_assignments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_party_assignment

    queries do
      get :get_work_effort_work_effort_party_assignment, :read
      list :list_work_effort_work_effort_party_assignments, :read
    end

    mutations do
      create :create_work_effort_work_effort_party_assignment, :create
      update :update_work_effort_work_effort_party_assignment, :update
      destroy :delete_work_effort_work_effort_party_assignment, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :status_date_time, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :must_rsvp, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :party, UniboExPoc.Ofbiz.WorkEffort.Party do
      public? true
      attribute_type :string
    end
    belongs_to :role_type, UniboExPoc.Ofbiz.WorkEffort.RoleType do
      public? true
      attribute_type :string
    end
    belongs_to :assigned_by_user_login, UniboExPoc.Ofbiz.WorkEffort.UserLogin do
      public? true
      attribute_type :string
    end
    belongs_to :assignment_status_item, UniboExPoc.Ofbiz.WorkEffort.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :expectation_enumeration, UniboExPoc.Ofbiz.WorkEffort.Enumeration do
      public? true
      source_attribute :expectation_enum_id
      attribute_type :string
    end
    belongs_to :delegate_reason_enumeration, UniboExPoc.Ofbiz.WorkEffort.Enumeration do
      public? true
      source_attribute :delegate_reason_enum_id
      attribute_type :string
    end
    belongs_to :facility, UniboExPoc.Ofbiz.WorkEffort.Facility do
      public? true
      attribute_type :string
    end
    belongs_to :availability_status_item, UniboExPoc.Ofbiz.WorkEffort.StatusItem do
      public? true
      source_attribute :availability_status_id
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
