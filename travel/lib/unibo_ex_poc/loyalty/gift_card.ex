# Workflow: giftcard_lifecycle_flow — 礼品卡激活-充值-消费完整流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> activate
#   activate --> topup
#   activate --> charge
#   activate --> cancel_card
#   activate --> expire_card
#   topup --> topup
#   topup --> charge
#   topup --> cancel_card
#   topup --> expire_card
#   charge --> topup
#   charge --> charge
#   charge --> cancel_card
#   charge --> expire_card
#   cancel_card --> [*]
#   expire_card --> [*]
# ```
defmodule UniboExPoc.Loyalty.GiftCard do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Loyalty.GiftCard.Notifier]

  resource do
    description "礼品卡，记录面值、当前余额、激活状态，支持充值与消费，可作为支付方式"
  end

  postgres do
    table "loyalty_gift_cards"
    repo UniboExPoc.Repo
  end

  graphql do
    type :loyalty_gift_card

    queries do
      get :get_loyalty_gift_card, :read
      list :list_loyalty_gift_cards, :read
    end

    mutations do
      create :create_loyalty_gift_card, :create
      update :activate_loyalty_gift_card, :activate
      update :topup_loyalty_gift_card, :topup
      update :charge_loyalty_gift_card, :charge
      update :cancel_card_loyalty_gift_card, :cancel_card
      update :expire_card_loyalty_gift_card, :expire_card
      destroy :delete_loyalty_gift_card, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :card_code, :string do
      allow_nil? false
      public? true
      description "礼品卡码（类似优惠码，唯一）"
    end
    attribute :pin_code, :string do
      public? true
      description "安全 PIN（可选，防止未授权使用）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:inactive, :active, :depleted, :expired, :cancelled]
      default :inactive
      public? true
      description "礼品卡状态"
    end
    attribute :initial_balance, :decimal do
      allow_nil? false
      public? true
      description "初始面值"
    end
    attribute :current_balance, :decimal do
      allow_nil? false
      public? true
      description "当前余额"
    end
    attribute :currency_id, :string do
      public? true
      description "货币代码（如 CNY/USD）"
    end
    attribute :from_date, :utc_datetime do
      public? true
      description "生效时间"
    end
    attribute :thru_date, :utc_datetime do
      public? true
      description "过期时间（映射 ProductPromoCode.thru_date）"
    end
    attribute :reloadable, :boolean do
      default false
      public? true
      description "是否支持充值"
    end
    attribute :is_physical, :boolean do
      default false
      public? true
      description "是否实体卡（影响发货逻辑）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :usage_percentage, :decimal, expr((((initial_balance - current_balance) / initial_balance) * 100))
  end

  relationships do
    belongs_to :program, UniboExPoc.Loyalty.LoyaltyProgram do
      public? true
    end
    has_many :transactions, UniboExPoc.Loyalty.GiftCardTransaction do
      public? true
      source_attribute :program_id
      destination_attribute :gift_card_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:card_code, :pin_code, :initial_balance, :currency_id, :from_date, :thru_date, :reloadable, :is_physical]
      argument :program_id, :uuid
      validate present(:card_code)
      change set_attribute(:id, expr(id))
    end
    update :activate do
      description "激活礼品卡，设置持卡人（inactive -> active）"
      primary? true
      accept []
      argument :owner_id, :uuid, allow_nil?: false
      argument :from_date, :utc_datetime
      change set_attribute(:status, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :topup do
      description "礼品卡充值（reloadable=true 时允许）"
      accept [:current_balance]
      argument :amount, :decimal, allow_nil?: false
      argument :payment_ref, :string
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :charge do
      description "消费扣款，余额不足则拒绝"
      accept [:current_balance]
      argument :amount, :decimal, allow_nil?: false
      argument :order_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel_card do
      description "作废礼品卡（active -> cancelled），余额退款逻辑由外部服务处理"
      accept []
      change set_attribute(:status, :cancelled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :expire_card do
      description "到期处理（active/depleted -> expired）"
      accept []
      change set_attribute(:status, :expired)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:initial_balance, greater_than: 0)
    validate compare(:current_balance, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_gift_card_code, [:card_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:transactions]
  end

end
