defmodule UniboV4.Ofbiz.WorkEffort.WorkEffortDeliverableProd do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_deliverable_prods"
    repo UniboV4.Repo
  end

  graphql do
    type :work_effort_work_effort_deliverable_prod

    queries do
      get :get_work_effort_work_effort_deliverable_prod, :read
      list :list_work_effort_work_effort_deliverable_prods, :read
    end

    mutations do
      create :create_work_effort_work_effort_deliverable_prod, :create
      update :update_work_effort_work_effort_deliverable_prod, :update
      destroy :delete_work_effort_work_effort_deliverable_prod, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboV4.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :deliverable, UniboV4.Ofbiz.WorkEffort.Deliverable do
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
