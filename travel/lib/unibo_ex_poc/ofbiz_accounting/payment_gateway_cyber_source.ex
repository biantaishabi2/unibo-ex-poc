defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayCyberSource do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_cyber_sources"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_cyber_source

    queries do
      get :get_accounting_payment_gateway_cyber_source, :read
      list :list_accounting_payment_gateway_cyber_sources, :read
    end

    mutations do
      create :create_accounting_payment_gateway_cyber_source, :create
      update :update_accounting_payment_gateway_cyber_source, :update
      destroy :delete_accounting_payment_gateway_cyber_source, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :merchant_id, :string do
      public? true
      description "您的商家ID"
    end
    attribute :api_version, :string do
      public? true
      description "目标CyberSource API版本"
    end
    attribute :production, :string do
      public? true
      description "启用生产\"模式\" (true|false)"
    end
    attribute :keys_dir, :string do
      public? true
      description "来自CyberSource的密钥目录（使用在线工具生成）"
    end
    attribute :keys_file, :string do
      public? true
      description "密钥库的名称（如果与\"merchantID\".p12不同）"
    end
    attribute :log_enabled, :string do
      public? true
      description "记录交易信息 (true|false)"
    end
    attribute :log_dir, :string do
      public? true
      description "日志目录"
    end
    attribute :log_file, :string do
      public? true
      description "日志文件名"
    end
    attribute :log_size, :integer do
      public? true
      description "最大日志大小 (MB)"
    end
    attribute :merchant_descr, :string do
      public? true
      description "商家描述 - 显示在信用卡账单中"
    end
    attribute :merchant_contact, :string do
      public? true
      description "商家描述联系信息 - 显示在信用卡账单中"
    end
    attribute :auto_bill, :string do
      public? true
      description "授权中的自动账单 (true|false)"
    end
    attribute :enable_dav, :boolean do
      public? true
      description "在授权中使用DAV -- 可能不再支持"
    end
    attribute :fraud_score, :boolean do
      public? true
      description "在授权中使用欺诈评分 -- 可能不再支持"
    end
    attribute :ignore_avs, :string do
      public? true
      description "忽略AVS结果 (true|false)"
    end
    attribute :disable_bill_avs, :boolean do
      public? true
      description "禁用捕获的AVS -- 可能不再支持"
    end
    attribute :avs_decline_codes, :string do
      public? true
      description "AVS拒绝代码 -- 可能不再支持"
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
