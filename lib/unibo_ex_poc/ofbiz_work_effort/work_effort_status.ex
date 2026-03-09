defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_status

    queries do
      get :get_work_effort_work_effort_status, :read
      list :list_work_effort_work_effort_statuss, :read
    end

    mutations do
      create :create_work_effort_work_effort_status, :create
      update :update_work_effort_work_effort_status, :update
      destroy :delete_work_effort_work_effort_status, :destroy
    end

  end

  attributes do
    attribute :status_datetime, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :reason, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.WorkEffort.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :set_by_user, UniboExPoc.Ofbiz.WorkEffort.UserLogin do
      public? true
      source_attribute :set_by_user_login
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
