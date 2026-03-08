defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortAssocTypeAttr do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_assoc_type_attrs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_assoc_type_attr

    queries do
      get :get_work_effort_work_effort_assoc_type_attr, :read
      list :list_work_effort_work_effort_assoc_type_attrs, :read
    end

    mutations do
      create :create_work_effort_work_effort_assoc_type_attr, :create
      update :update_work_effort_work_effort_assoc_type_attr, :update
      destroy :delete_work_effort_work_effort_assoc_type_attr, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort_assoc_type, UniboExPoc.Ofbiz.WorkEffort.WorkEffortAssocType do
      public? true
      attribute_type :string
    end
    has_many :work_effort_assoc_attribute, UniboExPoc.Ofbiz.WorkEffort.WorkEffortAssocAttribute do
      public? true
      source_attribute :work_effort_assoc_type_id
      destination_attribute :work_effort_assoc_type_id
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
    archive_related [:work_effort_assoc_attribute]
  end

end
