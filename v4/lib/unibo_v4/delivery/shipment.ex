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
defmodule UniboV4.Delivery.Delivery.Shipment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Delivery.Delivery.Shipment.Notifier]

  postgres do
    table "delivery_shipments"
    repo UniboV4.Repo
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
    attribute :shipment_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :primary_order_id, :string, public?: true
    attribute :primary_return_id, :string, public?: true
    attribute :primary_ship_group_seq_id, :string, public?: true
    attribute :estimated_ready_date, :utc_datetime, public?: true
    attribute :estimated_ship_date, :utc_datetime, public?: true
    attribute :estimated_arrival_date, :utc_datetime, public?: true
    attribute :latest_cancel_date, :utc_datetime, public?: true
    attribute :estimated_ship_cost, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :handling_instructions, :string, public?: true
    attribute :origin_contact_mech_id, :string, public?: true
    attribute :origin_telecom_number_id, :string, public?: true
    attribute :destination_contact_mech_id, :string, public?: true
    attribute :destination_telecom_number_id, :string, public?: true
    attribute :additional_shipping_charge, :decimal, public?: true
    attribute :addtl_shipping_charge_desc, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :total_weight
    # TODO: 不支持的 calculation 表达式 :package_count
    # TODO: 不支持的 calculation 表达式 :item_count
  end

  relationships do
    belongs_to :shipment_type, UniboV4.Delivery.Delivery.ShipmentType do
      public? true
    end
    belongs_to :origin_facility, UniboV4.Delivery.Delivery.Facility do
      public? true
    end
    belongs_to :destination_facility, UniboV4.Delivery.Delivery.Facility do
      public? true
    end
    belongs_to :to_party, UniboV4.Delivery.Delivery.Party do
      public? true
      source_attribute :party_id_to
    end
    belongs_to :from_party, UniboV4.Delivery.Delivery.Party do
      public? true
      source_attribute :party_id_from
    end
    has_many :shipment_items, UniboV4.Delivery.Delivery.ShipmentItem do
      public? true
      destination_attribute :shipment_id
    end
    has_many :shipment_packages, UniboV4.Delivery.Delivery.ShipmentPackage do
      public? true
      destination_attribute :shipment_id
    end
    has_many :route_segments, UniboV4.Delivery.Delivery.ShipmentRouteSegment do
      public? true
      destination_attribute :shipment_id
    end
    has_many :status_history, UniboV4.Delivery.Delivery.ShipmentStatus do
      public? true
      destination_attribute :shipment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_id, :primary_order_id, :estimated_ship_date, :estimated_arrival_date, :handling_instructions, :currency_uom_id, :estimated_ship_cost]
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

end
