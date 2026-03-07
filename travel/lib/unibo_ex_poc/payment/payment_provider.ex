# Workflow: payment_provider_lifecycle — 支付渠道配置生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> toggle_test_mode
#   create --> destroy
#   update --> activate
#   update --> toggle_test_mode
#   update --> destroy
#   activate --> update
#   activate --> toggle_test_mode
#   activate --> destroy
#   toggle_test_mode --> update
#   toggle_test_mode --> activate
#   toggle_test_mode --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Payment.PaymentProvider do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "支付渠道配置，将 OFBiz PaymentGatewayConfig 及各网关子表合并为统一实体，以 provider_type 区分网关类型"
  end

  postgres do
    table "payment_providers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_payment_provider

    queries do
      get :get_payment_payment_provider, :read
      list :list_payment_payment_providers, :read
    end

    mutations do
      create :create_payment_payment_provider, :create
      update :update_payment_payment_provider, :update
      update :activate_payment_payment_provider, :activate
      update :toggle_test_mode_payment_payment_provider, :toggle_test_mode
      destroy :delete_payment_payment_provider, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "渠道名称，如\"支付宝生产环境\""
    end
    attribute :provider_type, :string do
      allow_nil? false
      public? true
      description "网关类型标识，如 alipay、wechat、stripe 等，不硬编码枚举以支持自定义网关"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :test_mode, :boolean do
      default false
      public? true
      description "是否为沙箱/测试模式"
    end
    attribute :api_endpoint, :string do
      public? true
      description "API 接口 URL"
    end
    attribute :api_key, :string do
      public? true
      description "API 密钥（加密存储）"
    end
    attribute :api_secret, :string do
      public? true
      description "API 密文（加密存储）"
    end
    attribute :merchant_id, :string do
      public? true
      description "商户号"
    end
    attribute :description, :string do
      public? true
      description "配置说明"
    end
    attribute :config_type_id, :string do
      public? true
      description "对应 PaymentGatewayConfigType.payment_gateway_config_type_id"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :gateway_responses, UniboExPoc.Payment.PaymentGatewayResponse do
      public? true
      destination_attribute :payment_provider_id
    end
    has_many :tokens, UniboExPoc.Payment.PaymentToken do
      public? true
      destination_attribute :provider_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :provider_type, :is_active, :test_mode, :api_endpoint, :api_key, :api_secret, :merchant_id, :description, :config_type_id]
      validate present(:name)
      validate present(:provider_type)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :is_active, :test_mode, :api_endpoint, :api_key, :api_secret, :merchant_id, :description]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :activate do
      description "启用/禁用支付渠道"
      accept [:is_active]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :toggle_test_mode do
      description "切换沙箱/生产模式"
      accept [:test_mode]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:gateway_responses, :tokens]
  end

end
