defmodule UniboV4.Ofbiz.WorkEffort.WorkEffortSearchConstraint do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_search_constraints"
    repo UniboV4.Repo
  end

  graphql do
    type :work_effort_work_effort_search_constraint

    queries do
      get :get_work_effort_work_effort_search_constraint, :read
      list :list_work_effort_work_effort_search_constraints, :read
    end

    mutations do
      create :create_work_effort_work_effort_search_constraint, :create
      update :update_work_effort_work_effort_search_constraint, :update
      destroy :delete_work_effort_work_effort_search_constraint, :destroy
    end

  end

  attributes do
    attribute :constraint_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :constraint_name, :string, public?: true
    attribute :info_string, :string, public?: true
    attribute :include_sub_work_efforts, :boolean, public?: true
    attribute :is_and, :boolean, public?: true
    attribute :any_prefix, :boolean, public?: true
    attribute :any_suffix, :boolean, public?: true
    attribute :remove_stems, :boolean, public?: true
    attribute :low_value, :string, public?: true
    attribute :high_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort_search_result, UniboV4.Ofbiz.WorkEffort.WorkEffortSearchResult do
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
