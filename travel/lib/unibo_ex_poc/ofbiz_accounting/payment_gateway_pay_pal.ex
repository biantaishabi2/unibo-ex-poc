defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayPayPal do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_pay_pals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_pay_pal

    queries do
      get :get_accounting_payment_gateway_pay_pal, :read
      list :list_accounting_payment_gateway_pay_pals, :read
    end

    mutations do
      create :create_accounting_payment_gateway_pay_pal, :create
      update :update_accounting_payment_gateway_pay_pal, :update
      destroy :delete_accounting_payment_gateway_pay_pal, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :business_email, :string do
      public? true
      description "业务电子邮件"
    end
    attribute :api_user_name, :string do
      public? true
      description "PayPal API用户名"
    end
    attribute :api_password, :string do
      public? true
      description "PayPal API密码"
    end
    attribute :api_signature, :string do
      public? true
      description "PayPal API签名"
    end
    attribute :api_environment, :string do
      public? true
      description "PayPal API环境（有效值为：live、sandbox或beta-sandbox）"
    end
    attribute :notify_url, :string do
      public? true
      description "通知URL"
    end
    attribute :return_url, :string do
      public? true
      description "返回URL"
    end
    attribute :cancel_return_url, :string do
      public? true
      description "取消时返回URL"
    end
    attribute :image_url, :string do
      public? true
      description "在PayPal上使用的图像URL"
    end
    attribute :confirm_template, :string do
      public? true
      description "感谢/确认订单模板（通过Freemarker呈现）"
    end
    attribute :redirect_url, :string do
      public? true
      description "PayPal重定向URL（沙箱/生产）"
    end
    attribute :confirm_url, :string do
      public? true
      description "PayPal确认URL沙箱/生产（必须配置JSSE以使用SSL）"
    end
    attribute :shipping_callback_url, :string do
      public? true
      description "特定于快速结帐，该结帐对我们的服务器执行回调以检索运费估计"
    end
    attribute :require_confirmed_shipping, :boolean do
      public? true
      description "表示您要求与PayPal在档的客户的收货地址是确认的地址。"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_gateway_config, UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfig do
      public? true
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
