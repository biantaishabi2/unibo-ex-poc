defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayClearCommerce do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_clear_commerces"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_clear_commerce

    queries do
      get :get_accounting_payment_gateway_clear_commerce, :read
      list :list_accounting_payment_gateway_clear_commerces, :read
    end

    mutations do
      create :create_accounting_payment_gateway_clear_commerce, :create
      update :update_accounting_payment_gateway_clear_commerce, :update
      destroy :delete_accounting_payment_gateway_clear_commerce, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :source_id, :string do
      public? true
      description "用于标记交易"
    end
    attribute :group_id, :string do
      public? true
      description "用于分组交易"
    end
    attribute :client_id, :string do
      public? true
      description "账户信息的客户端ID"
    end
    attribute :username, :string do
      public? true
      description "账户信息的用户名"
    end
    attribute :pwd, :string do
      public? true
      description "账户信息的密码"
    end
    attribute :user_alias, :string do
      public? true
      description "账户信息的别名"
    end
    attribute :effective_alias, :string do
      public? true
      description "账户信息的有效别名"
    end
    attribute :process_mode, :boolean do
      public? true
      description "处理模式 (Y: 批准 / N: 拒绝 / R: 随机 / P: 生产)"
    end
    attribute :server_url, :string do
      public? true
      description "支付处理器的服务器URL"
    end
    attribute :enable_cvm, :boolean do
      public? true
      description "启用卡验证方法 (CID, CVC, CVV2)"
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
