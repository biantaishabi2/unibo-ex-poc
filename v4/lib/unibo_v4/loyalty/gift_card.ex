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
defmodule UniboV4.Loyalty.Loyalty.GiftCard do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Loyalty.Loyalty.GiftCard.Notifier]

  postgres do
    table "loyalty_gift_cards"
    repo UniboV4.Repo
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
    end
    attribute :pin_code, :string, public?: true
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:inactive, :active, :depleted, :expired, :cancelled]
      default :inactive
      public? true
    end
    attribute :initial_balance, :decimal do
      allow_nil? false
      public? true
    end
    attribute :current_balance, :decimal do
      allow_nil? false
      public? true
    end
    attribute :currency_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :reloadable, :boolean do
      default false
      public? true
    end
    attribute :is_physical, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :usage_percentage
  end

  relationships do
    belongs_to :program, UniboV4.Loyalty.Loyalty.LoyaltyProgram do
      public? true
    end
    belongs_to :owner, UniboV4.Loyalty.Loyalty.ResPartner do
      public? true
    end
    has_many :transactions, UniboV4.Loyalty.Loyalty.GiftCardTransaction do
      public? true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :activate do
      primary? true
      accept []
      argument :owner_id, :uuid, allow_nil?: false
      argument :from_date, :utc_datetime
      change set_attribute(:status, :active)
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
    update :topup do
      accept [:current_balance]
      argument :amount, :decimal, allow_nil?: false
      argument :payment_ref, :string
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
    update :charge do
      accept [:current_balance]
      argument :amount, :decimal, allow_nil?: false
      argument :order_id, :uuid
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
    update :cancel_card do
      accept []
      change set_attribute(:status, :cancelled)
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
    update :expire_card do
      accept []
      change set_attribute(:status, :expired)
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

  validations do
    # TODO: 不支持的校验规则 unique
    validate compare(:initial_balance, greater_than: 0)
    validate compare(:current_balance, greater_than_or_equal_to: 0)
  end

end
