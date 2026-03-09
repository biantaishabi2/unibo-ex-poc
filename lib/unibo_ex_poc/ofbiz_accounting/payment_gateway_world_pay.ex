defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayWorldPay do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_world_pays"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_world_pay

    queries do
      get :get_accounting_payment_gateway_world_pay, :read
      list :list_accounting_payment_gateway_world_pays, :read
    end

    mutations do
      create :create_accounting_payment_gateway_world_pay, :create
      update :update_accounting_payment_gateway_world_pay, :update
      destroy :delete_accounting_payment_gateway_world_pay, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :redirect_url, :string do
      public? true
      description "重定向URL"
    end
    attribute :inst_id, :string do
      public? true
      description "Worldpay实例ID"
    end
    attribute :auth_mode, :boolean do
      public? true
      description "授权模式 (A: 完全授权 / E: 预授权)"
    end
    attribute :fix_contact, :boolean do
      public? true
      description "将在WorldPay上以不可编辑格式取代联系信息"
    end
    attribute :hide_contact, :boolean do
      public? true
      description "将完全隐藏联系信息"
    end
    attribute :hide_currency, :boolean do
      public? true
      description "这导致货币下拉菜单不被隐藏，因此固定购物者必须购买价值的货币"
    end
    attribute :lang_id, :string do
      public? true
      description "购物者的语言选择，作为2字符ISO 639代码，可选择使用由连字符分隔的2字符国家/地区代码进行区域化"
    end
    attribute :no_language_menu, :boolean do
      public? true
      description "如果noLanguageMenu no，这会抑制语言菜单的显示，您可以为价值安装启用语言选择"
    end
    attribute :with_delivery, :boolean do
      public? true
      description "显示送货地址的输入字段，withDelivery no规定它们必须填入"
    end
    attribute :test_mode, :integer do
      public? true
      description "测试模式 (100: 批准 / 101: 已取消 / 0: 实时模式 (无测试))"
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
