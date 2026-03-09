# Workflow: payment_method_lifecycle — 支付方式生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> set_default
#   create --> expire
#   create --> destroy
#   update --> set_default
#   update --> expire
#   update --> destroy
#   set_default --> update
#   set_default --> expire
#   set_default --> destroy
#   expire --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Payment.PaymentMethod do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "支付方式，对应用户/客户绑定的具体支付手段（信用卡、银行账户、礼品卡等）"
  end

  postgres do
    table "payment_methods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_payment_method

    queries do
      get :get_payment_payment_method, :read
      list :list_payment_payment_methods, :read
    end

    mutations do
      create :create_payment_payment_method, :create
      update :update_payment_payment_method, :update
      update :set_default_payment_payment_method, :set_default
      update :expire_payment_payment_method, :expire
      destroy :delete_payment_payment_method, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method_type_id, :string do
      allow_nil? false
      public? true
      description "方式类型 ID，如 CREDIT_CARD / EFT_ACCOUNT / GIFT_CARD"
    end
    attribute :description, :string do
      public? true
      description "描述，如\"尾号6789的Visa卡\""
    end
    attribute :gl_account_id, :string do
      public? true
      description "关联总账科目（用于会计分录）"
    end
    attribute :fin_account_id, :string do
      public? true
      description "关联金融账户（预付账户/储值卡）"
    end
    attribute :from_date, :utc_datetime do
      public? true
      description "生效起始日期"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "生效截止日期（null 表示永久有效）"
    end
    attribute :is_default, :boolean do
      default false
      public? true
      description "是否为默认支付方式"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboExPoc.Payment.Party do
      public? true
    end
    has_many :payments, UniboExPoc.Payment.Payment do
      public? true
      destination_attribute :payment_method_id
    end
    has_many :gateway_responses, UniboExPoc.Payment.PaymentGatewayResponse do
      public? true
      destination_attribute :payment_method_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:party_id, :payment_method_type_id, :description, :gl_account_id, :fin_account_id, :from_date, :thru_date, :is_default]
      validate present(:party_id)
      validate present(:payment_method_type_id)
    end
    update :update do
      primary? true
      accept [:description, :gl_account_id, :fin_account_id, :from_date, :thru_date, :is_default]
      require_atomic? false
    end
    update :set_default do
      description "将该支付方式设为默认"
      accept [:is_default]
      require_atomic? false
    end
    update :expire do
      description "使支付方式过期（软删除）"
      accept [:thru_date]
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:payments, :gateway_responses]
  end

end
