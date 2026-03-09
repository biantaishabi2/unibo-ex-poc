defmodule UniboExPoc.Ofbiz.WorkEffort.DeliverableType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_deliverable_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_deliverable_type

    queries do
      get :get_work_effort_deliverable_type, :read
      list :list_work_effort_deliverable_types, :read
    end

    mutations do
      create :create_work_effort_deliverable_type, :create
      update :update_work_effort_deliverable_type, :update
      destroy :delete_work_effort_deliverable_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :deliverable_type_id, :string, public?: true
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
