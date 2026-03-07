defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewaySagePay do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_sage_pays"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_sage_pay

    queries do
      get :get_accounting_payment_gateway_sage_pay, :read
      list :list_accounting_payment_gateway_sage_pays, :read
    end

    mutations do
      create :create_accounting_payment_gateway_sage_pay, :create
      update :update_accounting_payment_gateway_sage_pay, :update
      destroy :delete_accounting_payment_gateway_sage_pay, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :vendor, :string do
      public? true
      description "供应商名称"
    end
    attribute :production_host, :string do
      public? true
      description "生产主机"
    end
    attribute :testing_host, :string do
      public? true
      description "测试主机"
    end
    attribute :sage_pay_mode, :string do
      public? true
      description "模式 (PRODUCTION/TEST)"
    end
    attribute :protocol_version, :string do
      public? true
      description "协议版本"
    end
    attribute :authentication_trans_type, :string do
      public? true
      description "身份验证类型 (PAYMENT/AUTHENTICATE/DEFERRED)"
    end
    attribute :authentication_url, :string do
      public? true
      description "身份验证URL"
    end
    attribute :authorise_trans_type, :string do
      public? true
      description "授权类型 (AUTHORISE/RELEASE)"
    end
    attribute :authorise_url, :string do
      public? true
      description "授权URL"
    end
    attribute :release_trans_type, :string do
      public? true
      description "发行类型 (CANCEL/ABORT)"
    end
    attribute :release_url, :string do
      public? true
      description "发布URL"
    end
    attribute :void_url, :string do
      public? true
      description "作废URL"
    end
    attribute :refund_url, :string do
      public? true
      description "退款URL"
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
