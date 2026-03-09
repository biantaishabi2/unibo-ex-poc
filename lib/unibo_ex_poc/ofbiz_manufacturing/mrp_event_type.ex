defmodule UniboExPoc.Ofbiz.Manufacturing.MrpEventType do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "manufacturing_mrp_event_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_mrp_event_type

    queries do
      get :get_manufacturing_mrp_event_type, :read
      list :list_manufacturing_mrp_event_types, :read
    end

    mutations do
      create :create_manufacturing_mrp_event_type, :create
      update :update_manufacturing_mrp_event_type, :update
      destroy :delete_manufacturing_mrp_event_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :mrp_event_type_id, :string do
      public? true
      description "MRP事件类型编号"
    end
    attribute :description, :string do
      public? true
      description "说明"
    end
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
