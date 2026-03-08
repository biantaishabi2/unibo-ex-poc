defmodule UniboV4.Ofbiz.Shipment.ShipmentGatewayUps do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Shipment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "shipment_gateway_upses"
    repo UniboV4.Repo
  end

  graphql do
    type :shipment_shipment_gateway_ups

    queries do
      get :get_shipment_shipment_gateway_ups, :read
      list :list_shipment_shipment_gateway_upss, :read
    end

    mutations do
      create :create_shipment_shipment_gateway_ups, :create
      update :update_shipment_shipment_gateway_ups, :update
      destroy :delete_shipment_shipment_gateway_ups, :destroy
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
      description "UPS 连接 URL"
    end
    attribute :connect_timeout, :integer do
      public? true
      description "超时时间（秒）"
    end
    attribute :shipper_number, :string do
      public? true
      description "UPS 发货人号"
    end
    attribute :bill_shipper_account_number, :string do
      public? true
      description "UPS 账单发货人账户号"
    end
    attribute :access_license_number, :string do
      public? true
      description "UPS XPCI 访问许可证号"
    end
    attribute :access_user_id, :string do
      public? true
      description "UPS XPCI 访问用户 ID"
    end
    attribute :access_password, :string do
      public? true
      description "UPS XPCI 访问密码"
    end
    attribute :save_cert_info, :string do
      public? true
      description "保存 UPS 认证所需文件的设置（true|false）"
    end
    attribute :save_cert_path, :string do
      public? true
      description "UPS 文件证书路径"
    end
    attribute :shipper_pickup_type, :string do
      public? true
      description "发货人默认取件方式"
    end
    attribute :customer_classification, :string do
      public? true
      description "客户分类"
    end
    attribute :max_estimate_weight, :decimal do
      public? true
      description "估算重量上限（分割成多个包）"
    end
    attribute :min_estimate_weight, :decimal do
      public? true
      description "包的最小重量"
    end
    attribute :cod_allow_cod, :string do
      public? true
      description "所有发货包裹项目来自已通过 EXT_COD 全额支付的订单"
    end
    attribute :cod_surcharge_amount, :decimal do
      public? true
      description "附加费金额"
    end
    attribute :cod_surcharge_currency_uom_id, :string do
      public? true
      description "附加费货币"
    end
    attribute :cod_surcharge_apply_to_package, :string do
      public? true
      description "附加费将应用于每个发货包裹"
    end
    attribute :cod_funds_code, :string do
      public? true
      description "表示 COD 付款资金类型的代码"
    end
    attribute :default_return_label_memo, :string do
      public? true
      description "退货标签电子邮件备忘录"
    end
    attribute :default_return_label_subject, :string do
      public? true
      description "退货标签主题"
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
