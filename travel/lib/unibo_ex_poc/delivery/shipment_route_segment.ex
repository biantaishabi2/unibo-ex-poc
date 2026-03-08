# Workflow: route_segment_flow — 运输路段生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> confirm_shipment
#   create --> update
#   create --> destroy
#   confirm_shipment --> update_tracking
#   confirm_shipment --> record_cost
#   update_tracking --> record_cost
#   record_cost --> [*]
#   update --> confirm_shipment
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentRouteSegment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Delivery.ShipmentRouteSegment.Notifier]

  resource do
    description "运输路段，记录承运商、追踪号、实际费用等，支持多段路线（转运）"
  end

  postgres do
    table "delivery_shipment_route_segments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_shipment_route_segment

    queries do
      get :get_delivery_shipment_route_segment, :read
      list :list_delivery_shipment_route_segments, :read
    end

    mutations do
      create :create_delivery_shipment_route_segment, :create
      update :update_delivery_shipment_route_segment, :update
      update :confirm_shipment_delivery_shipment_route_segment, :confirm_shipment
      update :update_tracking_delivery_shipment_route_segment, :update_tracking
      update :record_cost_delivery_shipment_route_segment, :record_cost
      destroy :delete_delivery_shipment_route_segment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_route_segment_id, :uuid do
      allow_nil? false
      public? true
      description "路段序号（OFBiz 复合主键）"
    end
    attribute :origin_contact_mech_id, :string do
      public? true
      description "出发地址"
    end
    attribute :origin_telecom_number_id, :string do
      public? true
      description "出发方电话"
    end
    attribute :dest_contact_mech_id, :string do
      public? true
      description "目的地址"
    end
    attribute :dest_telecom_number_id, :string do
      public? true
      description "目的方电话"
    end
    attribute :carrier_service_status_id, :string do
      public? true
      description "承运商服务状态"
    end
    attribute :carrier_delivery_zone, :string do
      public? true
      description "承运商配送区域编码"
    end
    attribute :carrier_restriction_codes, :string do
      public? true
      description "限制代码（危险品等）"
    end
    attribute :carrier_restriction_desc, :string do
      public? true
      description "限制说明"
    end
    attribute :billing_weight, :decimal do
      public? true
      description "计费重量"
    end
    attribute :billing_weight_uom_id, :string do
      public? true
      description "计费重量单位"
    end
    attribute :actual_transport_cost, :decimal do
      public? true
      description "实际运输费"
    end
    attribute :actual_service_cost, :decimal do
      public? true
      description "实际服务费"
    end
    attribute :actual_other_cost, :decimal do
      public? true
      description "实际其他费用"
    end
    attribute :actual_cost, :decimal do
      public? true
      description "实际总费用"
    end
    attribute :currency_uom_id, :string do
      public? true
      description "费用币种"
    end
    attribute :actual_start_date, :utc_datetime do
      public? true
      description "实际开始运输时间"
    end
    attribute :actual_arrival_date, :utc_datetime do
      public? true
      description "实际到达时间"
    end
    attribute :estimated_start_date, :utc_datetime do
      public? true
      description "预计开始时间"
    end
    attribute :estimated_arrival_date, :utc_datetime do
      public? true
      description "预计到达时间"
    end
    attribute :tracking_id_number, :string do
      public? true
      description "快递单号/追踪号"
    end
    attribute :tracking_digest, :string do
      public? true
      description "追踪摘要/签名"
    end
    attribute :home_delivery_type, :string do
      public? true
      description "家庭配送类型"
    end
    attribute :home_delivery_date, :utc_datetime do
      public? true
      description "预约上门日期"
    end
    attribute :third_party_account_number, :string do
      public? true
      description "第三方账号（到付）"
    end
    attribute :third_party_postal_code, :string do
      public? true
      description "第三方邮编（到付）"
    end
    attribute :third_party_country_geo_code, :string do
      public? true
      description "第三方国家代码（到付）"
    end
    attribute :updated_by_user_login_id, :string do
      public? true
      description "最后更新人"
    end
    attribute :last_updated_date, :utc_datetime do
      public? true
      description "最后更新时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Delivery.Shipment do
      public? true
    end
    belongs_to :delivery, UniboExPoc.Delivery.Delivery do
      public? true
    end
    belongs_to :carrier_party, UniboExPoc.Delivery.Party do
      public? true
    end
    belongs_to :shipment_method_type, UniboExPoc.Delivery.ShipmentMethodType do
      public? true
    end
    belongs_to :origin_facility, UniboExPoc.Delivery.Facility do
      public? true
    end
    belongs_to :dest_facility, UniboExPoc.Delivery.Facility do
      public? true
    end
    has_many :package_route_segs, UniboExPoc.Delivery.ShipmentPackageRouteSeg do
      public? true
      source_attribute :shipment_route_segment_id
      destination_attribute :shipment_route_segment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_id, :shipment_route_segment_id, :delivery_id, :carrier_party_id, :shipment_method_type_id, :origin_facility_id, :dest_facility_id, :estimated_start_date, :estimated_arrival_date]
      validate present(:shipment_id)
      validate present(:shipment_route_segment_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:tracking_id_number, :carrier_service_status_id, :actual_start_date, :actual_arrival_date, :actual_cost, :billing_weight]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :confirm_shipment do
      description "承运商接单"
      accept [:carrier_service_status_id, :tracking_id_number]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :update_tracking do
      description "更新追踪号"
      accept [:tracking_id_number, :tracking_digest]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :record_cost do
      description "录入实际费用"
      accept [:actual_transport_cost, :actual_service_cost, :actual_other_cost, :actual_cost, :currency_uom_id, :billing_weight, :billing_weight_uom_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:package_route_segs]
  end

end
