defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayPayflowPro do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_payflow_pros"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_payflow_pro

    queries do
      get :get_accounting_payment_gateway_payflow_pro, :read
      list :list_accounting_payment_gateway_payflow_pros, :read
    end

    mutations do
      create :create_accounting_payment_gateway_payflow_pro, :create
      update :update_accounting_payment_gateway_payflow_pro, :update
      destroy :delete_accounting_payment_gateway_payflow_pro, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :certs_path, :string do
      public? true
      description "VeriSign证书的路径"
    end
    attribute :host_address, :string do
      public? true
      description "支付处理器的地址"
    end
    attribute :host_port, :integer do
      public? true
      description "支付处理器的端口"
    end
    attribute :timeout, :integer do
      public? true
      description "超时"
    end
    attribute :proxy_address, :string do
      public? true
      description "代理地址"
    end
    attribute :proxy_port, :integer do
      public? true
      description "代理端口"
    end
    attribute :proxy_logon, :string do
      public? true
      description "代理登录"
    end
    attribute :proxy_password, :string do
      public? true
      description "代理密码"
    end
    attribute :vendor, :string do
      public? true
      description "账户信息的供应商"
    end
    attribute :user_id, :string do
      public? true
      description "账户信息的PayFlow UserID"
    end
    attribute :pwd, :string do
      public? true
      description "账户信息的PayFlow密码"
    end
    attribute :partner, :string do
      public? true
      description "账户信息的PayFlow伙伴"
    end
    attribute :check_avs, :boolean do
      public? true
      description "使用地址验证"
    end
    attribute :check_cvv2, :boolean do
      public? true
      description "要求CVV2验证"
    end
    attribute :pre_auth, :boolean do
      public? true
      description "预授权付款（如果设置为N将自动捕获）"
    end
    attribute :enable_transmit, :string do
      public? true
      description "设置为false以不传输任何内容"
    end
    attribute :log_file_name, :string do
      public? true
      description "日志文件名"
    end
    attribute :logging_level, :integer do
      public? true
      description "日志级别"
    end
    attribute :max_log_file_size, :integer do
      public? true
      description "最大日志文件大小"
    end
    attribute :stack_trace_on, :boolean do
      public? true
      description "堆栈跟踪打开/关闭"
    end
    attribute :redirect_url, :string do
      public? true
      description "快速结帐重定向URL"
    end
    attribute :return_url, :string do
      public? true
      description "快速结帐返回URL"
    end
    attribute :cancel_return_url, :string do
      public? true
      description "快速结帐取消时返回URL"
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
