defmodule UniboV4.Ofbiz.Accounting.PaymentGatewayAuthorizeNet do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_authorize_nets"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_payment_gateway_authorize_net

    queries do
      get :get_accounting_payment_gateway_authorize_net, :read
      list :list_accounting_payment_gateway_authorize_nets, :read
    end

    mutations do
      create :create_accounting_payment_gateway_authorize_net, :create
      update :update_accounting_payment_gateway_authorize_net, :update
      destroy :delete_accounting_payment_gateway_authorize_net, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :transaction_url, :string do
      public? true
      description "交易URL"
    end
    attribute :certificate_alias, :string do
      public? true
      description "证书别名"
    end
    attribute :api_version, :string do
      public? true
      description "目标 Authorize Dot Net API 版本"
    end
    attribute :delimited_data, :string do
      public? true
      description "分隔数据 (TRUE|FALSE)"
    end
    attribute :delimiter_char, :string do
      public? true
      description "分隔符字符 - 响应中使用的分隔符"
    end
    attribute :cp_version, :string do
      public? true
      description "卡片呈现版本"
    end
    attribute :cp_market_type, :string do
      public? true
      description "卡片呈现市场类型"
    end
    attribute :cp_device_type, :string do
      public? true
      description "卡片呈现设备类型"
    end
    attribute :method, :string do
      public? true
      description "方法 - CC用于信用卡处理"
    end
    attribute :email_customer, :string do
      public? true
      description "邮箱客户？ - 如果应该为每笔交易向客户发送邮件 (TRUE|FALSE)"
    end
    attribute :email_merchant, :string do
      public? true
      description "邮箱商家？ - 如果应该为每笔交易向商家发送邮件 (TRUE|FALSE)"
    end
    attribute :test_mode, :string do
      public? true
      description "测试模式 - 强制url属性为测试url，并向日志添加更多日志信息 (TRUE|FALSE)"
    end
    attribute :relay_response, :string do
      public? true
      description "中继响应？ - 如果应该将响应中继到其他服务器 (TRUE|FALSE)"
    end
    attribute :tran_key, :string do
      public? true
      description "交易密钥"
    end
    attribute :user_id, :string do
      public? true
      description "用户名 - 您的authorize.net用户ID"
    end
    attribute :pwd, :string do
      public? true
      description "密码 - 您的authorize.net密码"
    end
    attribute :trans_description, :string do
      public? true
      description "默认交易描述"
    end
    attribute :duplicate_window, :integer do
      public? true
      description "在指定的时间段内检查重复交易，该时间段以秒为单位指定。如果在定义的时间限制内发生重复交易，则返回错误。"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_gateway_config, UniboV4.Ofbiz.Accounting.PaymentGatewayConfig do
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
