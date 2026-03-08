defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortAttribute do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_attribute

    queries do
      get :get_work_effort_work_effort_attribute, :read
      list :list_work_effort_work_effort_attributes, :read
    end

    mutations do
      create :create_work_effort_work_effort_attribute, :create
      update :update_work_effort_work_effort_attribute, :update
      destroy :delete_work_effort_work_effort_attribute, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
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
