defmodule UniboExPoc.Ofbiz.Shipment.ShipmentGatewayUsps do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_gateway_uspses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_gateway_usps

    queries do
      get :get_shipment_shipment_gateway_usps, :read
      list :list_shipment_shipment_gateway_uspss, :read
    end

    mutations do
      create :create_shipment_shipment_gateway_usps, :create
      update :update_shipment_shipment_gateway_usps, :update
      destroy :delete_shipment_shipment_gateway_usps, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :connect_url, :string do
      public? true
      description "USPS 连接 URL"
    end
    attribute :connect_url_labels, :string do
      public? true
      description "USPS 标签连接 URL"
    end
    attribute :connect_timeout, :integer do
      public? true
      description "超时时间（秒）"
    end
    attribute :access_user_id, :string do
      public? true
      description "USPS 访问用户 ID"
    end
    attribute :access_password, :string do
      public? true
      description "USPS 访问密码"
    end
    attribute :max_estimate_weight, :integer do
      public? true
      description "估算重量上限（分割成多个包）"
    end
    attribute :test, :string do
      public? true
      description "测试/生产模式"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_gateway_config, UniboExPoc.Ofbiz.Shipment.ShipmentGatewayConfig do
      public? true
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
