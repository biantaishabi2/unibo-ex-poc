defmodule UniboExPoc.Ofbiz.Manufacturing.MrpEvent do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "manufacturing_mrp_events"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_mrp_event

    queries do
      get :get_manufacturing_mrp_event, :read
      list :list_manufacturing_mrp_events, :read
    end

    mutations do
      create :create_manufacturing_mrp_event, :create
      update :update_manufacturing_mrp_event, :update
      destroy :delete_manufacturing_mrp_event, :destroy
    end

  end

  attributes do
    attribute :mrp_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "MRP编号"
    end
    attribute :product_id, :string do
      allow_nil? false
      primary_key? true
      public? true
      description "产品编号"
    end
    attribute :event_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
      description "事件日期"
    end
    attribute :facility_id, :string do
      public? true
      description "设施编号"
    end
    attribute :quantity, :float do
      public? true
      description "数量"
    end
    attribute :event_name, :string do
      public? true
      description "事件名称"
    end
    attribute :is_late, :boolean do
      public? true
      description "是否延迟"
    end
    attribute :facility_id_to, :string do
      public? true
      description "目标设施编号"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :mrp_event_type, UniboExPoc.Ofbiz.Manufacturing.MrpEventType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
