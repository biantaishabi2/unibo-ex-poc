defmodule UniboExPoc.Ofbiz.WorkEffort.Timesheet do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_timesheets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_timesheet

    queries do
      get :get_work_effort_timesheet, :read
      list :list_work_effort_timesheets, :read
    end

    mutations do
      create :create_work_effort_timesheet, :create
      update :update_work_effort_timesheet, :update
      destroy :delete_work_effort_timesheet, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :timesheet_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Ofbiz.WorkEffort.Party do
      public? true
      attribute_type :string
    end
    belongs_to :client_party, UniboExPoc.Ofbiz.WorkEffort.Party do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.WorkEffort.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :approved_by_user_login, UniboExPoc.Ofbiz.WorkEffort.UserLogin do
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
