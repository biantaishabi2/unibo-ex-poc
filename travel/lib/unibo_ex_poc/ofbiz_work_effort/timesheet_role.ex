defmodule UniboExPoc.Ofbiz.WorkEffort.TimesheetRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_timesheet_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_timesheet_role

    queries do
      get :get_work_effort_timesheet_role, :read
      list :list_work_effort_timesheet_roles, :read
    end

    mutations do
      create :create_work_effort_timesheet_role, :create
      update :update_work_effort_timesheet_role, :update
      destroy :delete_work_effort_timesheet_role, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :timesheet, UniboExPoc.Ofbiz.WorkEffort.Timesheet do
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
