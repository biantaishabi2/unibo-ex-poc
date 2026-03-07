defmodule UniboExPoc.Ofbiz.Shipment.ShipmentGatewayDhl do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_gateway_dhls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :shipment_shipment_gateway_dhl

    queries do
      get :get_shipment_shipment_gateway_dhl, :read
      list :list_shipment_shipment_gateway_dhls, :read
    end

    mutations do
      create :create_shipment_shipment_gateway_dhl, :create
      update :update_shipment_shipment_gateway_dhl, :update
      destroy :delete_shipment_shipment_gateway_dhl, :destroy
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
      description "DHL 连接 URL"
    end
    attribute :connect_timeout, :integer do
      public? true
      description "超时时间（秒）"
    end
    attribute :head_version, :string do
      public? true
      description "头部版本属性"
    end
    attribute :head_action, :string do
      public? true
      description "头部操作属性"
    end
    attribute :access_user_id, :string do
      public? true
      description "您的 DHL ShipIT 用户 ID"
    end
    attribute :access_password, :string do
      public? true
      description "您的 DHL ShipIT 访问密码"
    end
    attribute :access_account_nbr, :string do
      public? true
      description "您的 DHL ShipIT 账户号"
    end
    attribute :access_shipping_key, :string do
      public? true
      description "您的 DHL ShipIT 发货密钥"
    end
    attribute :label_image_format, :string do
      public? true
      description "标签图片格式"
    end
    attribute :rate_estimate_template, :string do
      public? true
      description "API 模式模板"
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
