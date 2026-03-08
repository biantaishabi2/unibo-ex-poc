defmodule UniboV4.Ofbiz.WorkEffort.WorkEffortGoodStandard do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_good_standards"
    repo UniboV4.Repo
  end

  graphql do
    type :work_effort_work_effort_good_standard

    queries do
      get :get_work_effort_work_effort_good_standard, :read
      list :list_work_effort_work_effort_good_standards, :read
    end

    mutations do
      create :create_work_effort_work_effort_good_standard, :create
      update :update_work_effort_work_effort_good_standard, :update
      destroy :delete_work_effort_work_effort_good_standard, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :estimated_quantity, :float, public?: true
    attribute :estimated_cost, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboV4.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :work_effort_good_standard_type, UniboV4.Ofbiz.WorkEffort.WorkEffortGoodStandardType do
      public? true
      source_attribute :work_effort_good_std_type_id
      attribute_type :string
    end
    belongs_to :product, UniboV4.Ofbiz.WorkEffort.Product do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboV4.Ofbiz.WorkEffort.StatusItem do
      public? true
      source_attribute :status_id
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
