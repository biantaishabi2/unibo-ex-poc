defmodule UniboExPoc.Ofbiz.WorkEffort.Deliverable do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_deliverables"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_deliverable

    queries do
      get :get_work_effort_deliverable, :read
      list :list_work_effort_deliverables, :read
    end

    mutations do
      create :create_work_effort_deliverable, :create
      update :update_work_effort_deliverable, :update
      destroy :delete_work_effort_deliverable, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :deliverable_id, :string, public?: true
    attribute :deliverable_name, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :deliverable_type, UniboExPoc.Ofbiz.WorkEffort.DeliverableType do
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
