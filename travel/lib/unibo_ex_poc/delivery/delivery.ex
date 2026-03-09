# Workflow: delivery_trip_flow — 物流行程生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> start
#   create --> destroy
#   start --> arrive
#   arrive --> [*]
#   update --> start
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.Delivery do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "物流行程/配送任务，含起止设施、里程、油耗，用于自有车辆配送场景"
  end

  postgres do
    table "delivery_deliveries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_delivery

    queries do
      get :get_delivery_delivery, :read
      list :list_delivery_deliverys, :read
    end

    mutations do
      create :create_delivery_delivery, :create
      update :update_delivery_delivery, :update
      update :start_delivery_delivery, :start
      update :arrive_delivery_delivery, :arrive
      destroy :delete_delivery_delivery, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :delivery_id, :uuid do
      public? true
      description "OFBiz 原始 ID"
    end
    attribute :actual_start_date, :utc_datetime do
      public? true
      description "实际出发时间"
    end
    attribute :actual_arrival_date, :utc_datetime do
      public? true
      description "实际到达时间"
    end
    attribute :estimated_start_date, :utc_datetime do
      public? true
      description "预计出发时间"
    end
    attribute :estimated_arrival_date, :utc_datetime do
      public? true
      description "预计到达时间"
    end
    attribute :start_mileage, :decimal do
      public? true
      description "出发里程数（km）"
    end
    attribute :end_mileage, :decimal do
      public? true
      description "到达里程数（km）"
    end
    attribute :fuel_used, :decimal do
      public? true
      description "燃油消耗量（升）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :origin_facility, UniboExPoc.Delivery.Facility do
      public? true
    end
    belongs_to :dest_facility, UniboExPoc.Delivery.Facility do
      public? true
    end
    belongs_to :fixed_asset, UniboExPoc.Delivery.FixedAsset do
      public? true
    end
    has_many :route_segments, UniboExPoc.Delivery.ShipmentRouteSegment do
      public? true
      destination_attribute :delivery_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:delivery_id, :origin_facility_id, :dest_facility_id, :estimated_start_date, :estimated_arrival_date, :fixed_asset_id, :start_mileage]
      validate present(:origin_facility_id)
      validate present(:dest_facility_id)
    end
    update :update do
      primary? true
      accept [:actual_start_date, :actual_arrival_date, :end_mileage, :fuel_used]
      require_atomic? false
    end
    update :start do
      description "标记行程已出发"
      accept [:actual_start_date, :start_mileage]
      require_atomic? false
    end
    update :arrive do
      description "标记行程已到达"
      accept [:actual_arrival_date, :end_mileage, :fuel_used]
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:route_segments]
  end

end
