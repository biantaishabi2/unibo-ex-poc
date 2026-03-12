# Workflow: package_route_seg_flow — 包裹路段追踪流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update_label
#   create --> update_cost
#   create --> destroy
#   update_label --> mark_printed
#   update_label --> update_cost
#   mark_printed --> update_cost
#   update_cost --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentPackageRouteSeg do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "包裹路段追踪，记录每个包裹在每个路段的追踪码、面单和费用"
  end

  postgres do
    table "delivery_shipment_package_route_segs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_shipment_package_route_seg

    queries do
      get :get_delivery_shipment_package_route_seg, :read
      list :list_delivery_shipment_package_route_segs, :read
    end

    mutations do
      create :create_delivery_shipment_package_route_seg, :create
      update :update_label_delivery_shipment_package_route_seg, :update_label
      update :update_cost_delivery_shipment_package_route_seg, :update_cost
      update :mark_printed_delivery_shipment_package_route_seg, :mark_printed
      destroy :delete_delivery_shipment_package_route_seg, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tracking_code, :string do
      public? true
      description "包裹级别追踪码"
    end
    attribute :box_number, :string do
      public? true
      description "箱号"
    end
    attribute :label_image, :string do
      public? true
      description "面单图片（Base64/URL）"
    end
    attribute :label_html, :string do
      public? true
      description "面单 HTML"
    end
    attribute :label_printed, :boolean do
      default false
      public? true
      description "是否已打印面单"
    end
    attribute :package_transport_cost, :decimal do
      public? true
      description "包裹运输费"
    end
    attribute :package_service_cost, :decimal do
      public? true
      description "包裹服务费"
    end
    attribute :package_other_cost, :decimal do
      public? true
      description "包裹其他费"
    end
    attribute :cod_amount, :decimal do
      public? true
      description "货到付款金额"
    end
    attribute :insured_amount, :decimal do
      public? true
      description "保险金额"
    end
    attribute :currency_uom_id, :string do
      public? true
      description "费用币种"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment, UniboExPoc.Delivery.Shipment do
      public? true
    end
    belongs_to :shipment_package, UniboExPoc.Delivery.ShipmentPackage do
      public? true
      source_attribute :shipment_package_seq_id
    end
    belongs_to :route_segment, UniboExPoc.Delivery.ShipmentRouteSegment do
      public? true
      source_attribute :shipment_route_segment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Shipment Package Route Seg via Create. doc_url: graphql://contract/delivery/create_delivery_shipment_package_route_seg"
      primary? true
      accept [:shipment_id, :shipment_package_seq_id, :shipment_route_segment_id, :tracking_code]
      validate present(:shipment_id)
      validate present(:shipment_package_seq_id)
      validate present(:shipment_route_segment_id)
    end
    update :update_label do
      description "更新面单

更新面单. doc_url: graphql://contract/delivery/update_label_delivery_shipment_package_route_seg"
      primary? true
      accept [:label_image, :label_html, :label_printed]
      require_atomic? false
    end
    update :update_cost do
      description "更新费用

更新费用. doc_url: graphql://contract/delivery/update_cost_delivery_shipment_package_route_seg"
      accept [:package_transport_cost, :package_service_cost, :package_other_cost, :cod_amount, :insured_amount, :currency_uom_id]
      require_atomic? false
    end
    update :mark_printed do
      description "标记已打印面单

标记已打印面单. doc_url: graphql://contract/delivery/mark_printed_delivery_shipment_package_route_seg"
      accept []
      change set_attribute(:label_printed, true)
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
