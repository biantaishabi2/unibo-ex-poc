defmodule UniboV4.Ofbiz.Shipment.ShipmentGatewayFedex do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_gateway_fedexes"
    repo UniboV4.Repo
  end

  graphql do
    type :shipment_shipment_gateway_fedex

    queries do
      get :get_shipment_shipment_gateway_fedex, :read
      list :list_shipment_shipment_gateway_fedexs, :read
    end

    mutations do
      create :create_shipment_shipment_gateway_fedex, :create
      update :update_shipment_shipment_gateway_fedex, :update
      destroy :delete_shipment_shipment_gateway_fedex, :destroy
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
      description "FedEx 连接 URL"
    end
    attribute :connect_soap_url, :string do
      public? true
      description "FedEx Soap 连接 URL"
    end
    attribute :connect_timeout, :integer do
      public? true
      description "超时时间（秒）"
    end
    attribute :access_account_nbr, :string do
      public? true
      description "您的 FedEx 账户号"
    end
    attribute :access_meter_number, :string do
      public? true
      description "您的 FedEx 电表号"
    end
    attribute :access_user_key, :string do
      public? true
      description "您的 FedEx 用户凭证密钥"
    end
    attribute :access_user_pwd, :string do
      public? true
      description "您的 FedEx 用户凭证密码"
    end
    attribute :label_image_type, :string do
      public? true
      description "标签图片类型"
    end
    attribute :default_dropoff_type, :string do
      public? true
      description "默认投递方式"
    end
    attribute :default_packaging_type, :string do
      public? true
      description "默认包装类型"
    end
    attribute :template_shipment, :string do
      public? true
      description "发货模板位置"
    end
    attribute :template_subscription, :string do
      public? true
      description "订阅模板位置"
    end
    attribute :rate_estimate_template, :string do
      public? true
      description "FedEx API 费率估算模板"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :shipment_gateway_config, UniboV4.Ofbiz.Shipment.ShipmentGatewayConfig do
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
