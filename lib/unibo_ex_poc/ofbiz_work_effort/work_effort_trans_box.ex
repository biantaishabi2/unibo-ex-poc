defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortTransBox do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_trans_boxes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_trans_box

    queries do
      get :get_work_effort_work_effort_trans_box, :read
      list :list_work_effort_work_effort_trans_boxs, :read
    end

    mutations do
      create :create_work_effort_work_effort_trans_box, :create
      update :update_work_effort_work_effort_trans_box, :update
      destroy :delete_work_effort_work_effort_trans_box, :destroy
    end

  end

  attributes do
    attribute :to_activity_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :transition_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      source_attribute :process_work_effort_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
