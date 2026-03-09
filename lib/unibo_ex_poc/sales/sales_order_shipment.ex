# Workflow: shipment_lifecycle — 发货流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> ship
#   ship --> deliver
#   deliver --> [*] : delivered
# ```
defmodule UniboExPoc.Sales.SalesOrderShipment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Sales.SalesOrderShipment.Notifier]

  resource do
    description "销售发货单"
  end

  postgres do
    table "sales_order_shipments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sales_sales_order_shipment

    queries do
      get :get_sales_sales_order_shipment, :read
      list :list_sales_sales_order_shipments, :read
      get :get_list_sales_sales_order_shipment, :list
      list :list_list_sales_sales_order_shipments, :list
      get :get_search_sales_sales_order_shipment, :search
      list :list_search_sales_sales_order_shipments, :search
      get :get_get_sales_sales_order_shipment, :get
      list :list_get_sales_sales_order_shipments, :get
      get :get_preview_sales_sales_order_shipment, :preview
      list :list_preview_sales_sales_order_shipments, :preview
      get :get_compute_sales_sales_order_shipment, :compute
      list :list_compute_sales_sales_order_shipments, :compute
      get :get_lookup_sales_sales_order_shipment, :lookup
      list :list_lookup_sales_sales_order_shipments, :lookup
    end

    mutations do
      create :create_sales_sales_order_shipment, :create
      update :ship_sales_sales_order_shipment, :ship
      update :deliver_sales_sales_order_shipment, :deliver
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_number, :string do
      allow_nil? false
      public? true
      description "发货单号"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :shipped, :delivered, :cancelled]
      default :draft
      public? true
    end
    attribute :ship_date, :date, public?: true
    attribute :delivery_date, :date, public?: true
    attribute :carrier, :string do
      public? true
      description "承运商"
    end
    attribute :tracking_number, :string do
      public? true
      description "物流单号"
    end
    attribute :shipping_address, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :sales_order, UniboExPoc.Sales.SalesOrder do
      public? true
      allow_nil? false
    end
    belongs_to :shipped_by, UniboExPoc.Sales.Party do
      public? true
      source_attribute :shipped_by_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:shipment_number, :ship_date, :carrier, :tracking_number, :shipping_address, :notes]
      argument :sales_order_id, :uuid, allow_nil?: false
      change manage_relationship(:sales_order_id, :sales_order, type: :append, on_lookup: :relate)
      validate present(:shipment_number)
      change relate_actor(:shipped_by)
      change set_attribute(:id, expr(id))
    end
    read :list do
      description "列表查询"
    end
    read :search do
      description "条件检索"
    end
    read :get do
      description "详情查询"
    end
    read :preview do
      description "预览查询"
    end
    read :compute do
      description "计算查询"
    end
    read :lookup do
      description "快速检索"
    end
    update :ship do
      description "标记已发货"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发货"
      change set_attribute(:status, :shipped)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deliver do
      description "标记已送达"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :shipped do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :shipped}))
        end
      end
      # message: "只有已发货状态可以标记送达"
      change set_attribute(:status, :delivered)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_shipment_number, [:shipment_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
