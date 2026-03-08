# Workflow: shipment_lifecycle_flow — 发货单生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> submit
#   create --> destroy
#   submit --> pick
#   submit --> cancel
#   pick --> pack
#   pick --> cancel
#   pack --> ship
#   ship --> deliver
#   deliver --> [*]
#   cancel --> [*]
#   update --> submit
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.Shipment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Delivery.Shipment.Notifier]

  resource do
    description "发货单，管理出货/入货/调拨/退货的全生命周期"
  end

  postgres do
    table "delivery_shipments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_shipment

    queries do
      get :get_delivery_shipment, :read
      list :list_delivery_shipments, :read
    end

    mutations do
      create :create_delivery_shipment, :create
      update :update_delivery_shipment, :update
      update :submit_delivery_shipment, :submit
      update :pick_delivery_shipment, :pick
      update :pack_delivery_shipment, :pack
      update :ship_delivery_shipment, :ship
      update :deliver_delivery_shipment, :deliver
      update :cancel_delivery_shipment, :cancel
      destroy :delete_delivery_shipment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_id, :uuid do
      public? true
      description "OFBiz 原始 ID"
    end
    attribute :status_id, :string do
      public? true
      description "当前状态"
    end
    attribute :primary_order_id, :string do
      public? true
      description "关联的主销售订单 ID"
    end
    attribute :primary_return_id, :string do
      public? true
      description "关联的退货单 ID"
    end
    attribute :primary_ship_group_seq_id, :string do
      public? true
      description "订单发货组序号"
    end
    attribute :estimated_ready_date, :utc_datetime do
      public? true
      description "预计备货完成时间"
    end
    attribute :estimated_ship_date, :utc_datetime do
      public? true
      description "预计发货时间"
    end
    attribute :estimated_arrival_date, :utc_datetime do
      public? true
      description "预计到达时间"
    end
    attribute :latest_cancel_date, :utc_datetime do
      public? true
      description "最晚可取消时间"
    end
    attribute :estimated_ship_cost, :decimal do
      public? true
      description "预估运费"
    end
    attribute :currency_uom_id, :string do
      public? true
      description "运费币种（FK->Uom）"
    end
    attribute :handling_instructions, :string do
      public? true
      description "特殊搬运说明"
    end
    attribute :origin_contact_mech_id, :string do
      public? true
      description "发货地址（ContactMech）"
    end
    attribute :origin_telecom_number_id, :string do
      public? true
      description "发货方联系电话"
    end
    attribute :destination_contact_mech_id, :string do
      public? true
      description "收货地址（ContactMech）"
    end
    attribute :destination_telecom_number_id, :string do
      public? true
      description "收货方联系电话"
    end
    attribute :additional_shipping_charge, :decimal do
      public? true
      description "额外运费"
    end
    attribute :addtl_shipping_charge_desc, :string do
      public? true
      description "额外运费说明"
    end
    attribute :created_date, :utc_datetime do
      public? true
      description "OFBiz 创建时间"
    end
    attribute :created_by_user_login, :string do
      public? true
      description "OFBiz 创建人"
    end
    attribute :last_modified_date, :utc_datetime do
      public? true
      description "OFBiz 最后修改时间"
    end
    attribute :last_modified_by_user_login, :string do
      public? true
      description "OFBiz 最后修改人"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :total_weight, :decimal, {UniboExPoc.Delivery.Calculations.Shipment.TotalWeight, []}
    calculate :package_count, :integer, {UniboExPoc.Delivery.Calculations.Shipment.PackageCount, []}
    calculate :item_count, :integer, {UniboExPoc.Delivery.Calculations.Shipment.ItemCount, []}
  end

  relationships do
    belongs_to :shipment_type, UniboExPoc.Delivery.ShipmentType do
      public? true
    end
    belongs_to :origin_facility, UniboExPoc.Delivery.Facility do
      public? true
    end
    belongs_to :destination_facility, UniboExPoc.Delivery.Facility do
      public? true
    end
    belongs_to :to_party, UniboExPoc.Delivery.Party do
      public? true
      source_attribute :party_id_to
    end
    belongs_to :from_party, UniboExPoc.Delivery.Party do
      public? true
      source_attribute :party_id_from
    end
    has_many :shipment_items, UniboExPoc.Delivery.ShipmentItem do
      public? true
      source_attribute :shipment_id
      destination_attribute :shipment_id
    end
    has_many :shipment_packages, UniboExPoc.Delivery.ShipmentPackage do
      public? true
      source_attribute :shipment_id
      destination_attribute :shipment_id
    end
    has_many :route_segments, UniboExPoc.Delivery.ShipmentRouteSegment do
      public? true
      source_attribute :shipment_id
      destination_attribute :shipment_id
    end
    has_many :status_history, UniboExPoc.Delivery.ShipmentStatus do
      public? true
      source_attribute :shipment_id
      destination_attribute :shipment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_id, :shipment_type_id, :primary_order_id, :origin_facility_id, :destination_facility_id, :party_id_to, :party_id_from, :estimated_ship_date, :estimated_arrival_date, :handling_instructions, :currency_uom_id, :estimated_ship_cost]
      validate present(:shipment_type_id)
      change set_attribute(:status_id, :SHIPMENT_INPUT)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:status_id, :handling_instructions, :estimated_ship_date, :estimated_arrival_date, :additional_shipping_charge]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :submit do
      description "提交待处理（-> SHIPMENT_INPUT）"
      accept []
      change set_attribute(:status_id, :SHIPMENT_INPUT)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :pick do
      description "确认拣货（-> SHIPMENT_SCHEDULED）"
      accept []
      change set_attribute(:status_id, :SHIPMENT_SCHEDULED)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :pack do
      description "确认打包（-> SHIPMENT_PACKED）"
      accept []
      change set_attribute(:status_id, :SHIPMENT_PACKED)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :ship do
      description "标记已发出（-> SHIPMENT_SHIPPED）"
      accept []
      change set_attribute(:status_id, :SHIPMENT_SHIPPED)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :deliver do
      description "标记已收货（-> SHIPMENT_DELIVERED）"
      accept []
      change set_attribute(:status_id, :SHIPMENT_DELIVERED)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :cancel do
      description "取消发货单（-> SHIPMENT_CANCELLED）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status_id)
        if current in [:SHIPMENT_INPUT, :SHIPMENT_SCHEDULED] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status_id, message: "must be one of %{values}", vars: %{values: [:SHIPMENT_INPUT, :SHIPMENT_SCHEDULED]}))
        end
      end
      # message: "已发出的发货单不能直接取消，需走逆向退货流程"
      change set_attribute(:status_id, :SHIPMENT_CANCELLED)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:shipment_items, :shipment_packages, :route_segments, :status_history]
  end

end
