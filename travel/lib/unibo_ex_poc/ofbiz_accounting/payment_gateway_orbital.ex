defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayOrbital do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_orbitals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_orbital

    queries do
      get :get_accounting_payment_gateway_orbital, :read
      list :list_accounting_payment_gateway_orbitals, :read
    end

    mutations do
      create :create_accounting_payment_gateway_orbital, :create
      update :update_accounting_payment_gateway_orbital, :update
      destroy :delete_accounting_payment_gateway_orbital, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :username, :string do
      public? true
      description "账户信息的Orbital用户名"
    end
    attribute :connection_password, :string do
      public? true
      description "账户信息的Orbital密码"
    end
    attribute :merchant_id, :string do
      public? true
      description "您的商家ID"
    end
    attribute :engine_class, :string do
      public? true
      description "Orbital网关的类 - 应使用默认值 - HttpsEngine"
    end
    attribute :host_name, :string do
      public? true
      description "支付处理器的地址"
    end
    attribute :port, :integer do
      public? true
      description "支付处理器的端口"
    end
    attribute :host_name_failover, :string do
      public? true
      description "支付处理器的故障转移地址"
    end
    attribute :port_failover, :integer do
      public? true
      description "支付处理器的故障转移端口"
    end
    attribute :connection_timeout_seconds, :integer do
      public? true
      description "超时"
    end
    attribute :read_timeout_seconds, :integer do
      public? true
      description "读取超时"
    end
    attribute :authorization_uri, :string do
      public? true
      description "授权URI"
    end
    attribute :sdk_version, :string do
      public? true
      description "目标Orbital网关API版本"
    end
    attribute :ssl_socket_factory, :string do
      public? true
      description "SSL套接字工厂 (default|strict)"
    end
    attribute :response_type, :string do
      public? true
      description "响应类型 (gateway|host)"
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
