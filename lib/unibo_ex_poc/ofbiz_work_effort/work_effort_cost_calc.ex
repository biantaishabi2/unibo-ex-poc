defmodule UniboV4.Ofbiz.WorkEffort.WorkEffortCostCalc do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_cost_calcs"
    repo UniboV4.Repo
  end

  graphql do
    type :work_effort_work_effort_cost_calc

    queries do
      get :get_work_effort_work_effort_cost_calc, :read
      list :list_work_effort_work_effort_cost_calcs, :read
    end

    mutations do
      create :create_work_effort_work_effort_cost_calc, :create
      update :update_work_effort_work_effort_cost_calc, :update
      destroy :delete_work_effort_work_effort_cost_calc, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboV4.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :cost_component_type, UniboV4.Ofbiz.WorkEffort.CostComponentType do
      public? true
      attribute_type :string
    end
    belongs_to :cost_component_calc, UniboV4.Ofbiz.WorkEffort.CostComponentCalc do
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
