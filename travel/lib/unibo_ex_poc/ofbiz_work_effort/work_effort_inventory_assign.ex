defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortInventoryAssign do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_inventory_assigns"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_inventory_assign

    queries do
      get :get_work_effort_work_effort_inventory_assign, :read
      list :list_work_effort_work_effort_inventory_assigns, :read
    end

    mutations do
      create :create_work_effort_work_effort_inventory_assign, :create
      update :update_work_effort_work_effort_inventory_assign, :update
      destroy :delete_work_effort_work_effort_inventory_assign, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :float, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :inventory_item, UniboExPoc.Ofbiz.WorkEffort.InventoryItem do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboExPoc.Ofbiz.WorkEffort.StatusItem do
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
