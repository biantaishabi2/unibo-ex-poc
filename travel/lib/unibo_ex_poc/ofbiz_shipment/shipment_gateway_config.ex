defmodule UniboExPoc.Ofbiz.Shipment.ShipmentGatewayConfig do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_gateway_configs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_gateway_config

    queries do
      get :get_shipment_shipment_gateway_config, :read
      list :list_shipment_shipment_gateway_configs, :read
    end

    mutations do
      create :create_shipment_shipment_gateway_config, :create
      update :update_shipment_shipment_gateway_config, :update
      destroy :delete_shipment_shipment_gateway_config, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :shipment_gateway_config_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_gateway_config_type, UniboExPoc.Ofbiz.Shipment.ShipmentGatewayConfigType do
      public? true
      source_attribute :shipment_gateway_conf_type_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
