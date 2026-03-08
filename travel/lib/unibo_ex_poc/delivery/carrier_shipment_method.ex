# Workflow: carrier_method_bind_flow — 承运商运输方式绑定管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.CarrierShipmentMethod do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "承运商与运输方式绑定关系，含优先级排序和服务代码"
  end

  postgres do
    table "delivery_carrier_shipment_methods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_carrier_shipment_method

    queries do
      get :get_delivery_carrier_shipment_method, :read
      list :list_delivery_carrier_shipment_methods, :read
    end

    mutations do
      create :create_delivery_carrier_shipment_method, :create
      update :update_delivery_carrier_shipment_method, :update
      destroy :delete_delivery_carrier_shipment_method, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role_type_id, :string do
      allow_nil? false
      public? true
      description "承运商角色（CARRIER）"
    end
    attribute :sequence_number, :integer do
      public? true
      description "优先级排序"
    end
    attribute :carrier_service_code, :string do
      public? true
      description "承运商内部服务代码"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_method_type, UniboExPoc.Delivery.ShipmentMethodType do
      public? true
    end
    belongs_to :carrier_party, UniboExPoc.Delivery.Party do
      public? true
      source_attribute :party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:shipment_method_type_id, :party_id, :role_type_id, :sequence_number, :carrier_service_code]
      validate present(:shipment_method_type_id)
      validate present(:party_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:sequence_number, :carrier_service_code]
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
  end

end
