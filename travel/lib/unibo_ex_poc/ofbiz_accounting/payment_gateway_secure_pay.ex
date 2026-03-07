defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewaySecurePay do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_secure_pays"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_secure_pay

    queries do
      get :get_accounting_payment_gateway_secure_pay, :read
      list :list_accounting_payment_gateway_secure_pays, :read
    end

    mutations do
      create :create_accounting_payment_gateway_secure_pay, :create
      update :update_accounting_payment_gateway_secure_pay, :update
      destroy :delete_accounting_payment_gateway_secure_pay, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :merchant_id, :string do
      public? true
      description "您的商家ID"
    end
    attribute :pwd, :string do
      public? true
      description "账户信息的SecurePay密码"
    end
    attribute :server_url, :string do
      public? true
      description "支付处理器的服务器URL"
    end
    attribute :process_timeout, :integer do
      public? true
      description "处理超时"
    end
    attribute :enable_amount_round, :boolean do
      public? true
      description "启用将货币金额四舍五入到.00 (Y / N)"
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
