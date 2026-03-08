# Workflow: shipment_status_record_flow — 状态历史记录
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "发货单状态变更历史记录"
  end

  postgres do
    table "delivery_shipment_statuses"
    repo UniboV4.Repo
  end

  graphql do
    type :delivery_shipment_status

    queries do
      get :get_delivery_shipment_status, :read
      list :list_delivery_shipment_statuss, :read
    end

    mutations do
      create :create_delivery_shipment_status, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :status_id, :string do
      allow_nil? false
      public? true
      description "状态编码"
    end
    attribute :status_date, :utc_datetime do
      public? true
      description "状态变更时间"
    end
    attribute :change_by_user_login_id, :string do
      public? true
      description "操作人"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment, UniboV4.Delivery.Shipment do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:shipment_id, :status_id, :status_date, :change_by_user_login_id]
      validate present(:shipment_id)
      validate present(:status_id)
      change set_attribute(:id, expr(id))
    end
  end

end
