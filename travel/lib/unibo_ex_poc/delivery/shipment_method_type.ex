# Workflow: shipment_method_type_maintain_flow — 运输方式维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Delivery.ShipmentMethodType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Delivery,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "运输方式字典，如标准快递、加急快递、次日达等"
  end

  postgres do
    table "delivery_shipment_method_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :delivery_shipment_method_type

    queries do
      get :get_delivery_shipment_method_type, :read
      list :list_delivery_shipment_method_types, :read
    end

    mutations do
      create :create_delivery_shipment_method_type, :create
      update :update_delivery_shipment_method_type, :update
      destroy :delete_delivery_shipment_method_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :shipment_method_type_id, :uuid do
      public? true
      description "OFBiz 编码（如 STANDARD、EXPRESS）"
    end
    attribute :description, :string do
      public? true
      description "方式描述"
    end
    attribute :sequence_num, :integer do
      public? true
      description "排序号"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :carrier_shipment_methods, UniboExPoc.Delivery.CarrierShipmentMethod do
      public? true
      destination_attribute :shipment_method_type_id
    end
    has_many :cost_estimates, UniboExPoc.Delivery.ShipmentCostEstimate do
      public? true
      destination_attribute :shipment_method_type_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Shipment Method Type via Create. doc_url: graphql://contract/delivery/create_delivery_shipment_method_type"
      primary? true
      accept [:shipment_method_type_id, :description, :sequence_num]
    end
    update :update do
      description "Update Shipment Method Type via Update. doc_url: graphql://contract/delivery/update_delivery_shipment_method_type"
      primary? true
      accept [:description, :sequence_num]
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:carrier_shipment_methods, :cost_estimates]
  end

end
