# Workflow: card_lifecycle_flow — 会员积分卡生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> earn_points
#   create --> redeem_points
#   create --> freeze
#   create --> expire_card
#   earn_points --> earn_points
#   earn_points --> redeem_points
#   earn_points --> freeze
#   earn_points --> expire_card
#   redeem_points --> earn_points
#   redeem_points --> redeem_points
#   redeem_points --> freeze
#   redeem_points --> expire_card
#   freeze --> unfreeze
#   unfreeze --> earn_points
#   unfreeze --> redeem_points
#   unfreeze --> freeze
#   unfreeze --> expire_card
#   expire_card --> [*]
# ```
defmodule UniboExPoc.Loyalty.LoyaltyCard do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Loyalty.LoyaltyCard.Notifier]

  resource do
    description "会员积分卡，记录持卡人当前积分余额与生命周期状态"
  end

  postgres do
    table "loyalty_cards"
    repo UniboExPoc.Repo
  end

  graphql do
    type :loyalty_loyalty_card

    queries do
      get :get_loyalty_loyalty_card, :read
      list :list_loyalty_loyalty_cards, :read
    end

    mutations do
      create :create_loyalty_loyalty_card, :create
      update :earn_points_loyalty_loyalty_card, :earn_points
      update :redeem_points_loyalty_loyalty_card, :redeem_points
      update :freeze_loyalty_loyalty_card, :freeze
      update :unfreeze_loyalty_loyalty_card, :unfreeze
      update :expire_card_loyalty_loyalty_card, :expire_card
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :card_number, :string do
      allow_nil? false
      public? true
      description "卡号（唯一，系统自动生成）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:active, :frozen, :expired, :cancelled]
      default :active
      public? true
      description "卡状态"
    end
    attribute :points_balance, :decimal do
      allow_nil? false
      default 0
      public? true
      description "当前积分余额"
    end
    attribute :lifetime_points_earned, :decimal do
      default 0
      public? true
      description "历史累计获取积分（用于升级判断）"
    end
    attribute :expiry_date, :date do
      public? true
      description "积分卡到期日"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :points_to_next_tier, :decimal, expr(compute_points_to_next_tier(lifetime_points_earned))
  end

  relationships do
    belongs_to :program, UniboExPoc.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    has_many :transactions, UniboExPoc.Loyalty.LoyaltyTransaction do
      public? true
      source_attribute :program_id
      destination_attribute :card_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:card_number, :expiry_date]
      argument :program_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :earn_points do
      description "增加积分（消费/活动奖励），触发 LoyaltyTransaction 写入"
      primary? true
      accept [:points_balance, :lifetime_points_earned]
      argument :points_delta, :decimal, allow_nil?: false
      argument :order_id, :uuid
      argument :reason, :string
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :redeem_points do
      description "扣减积分（兑换奖励），余额不足则拒绝"
      accept [:points_balance]
      argument :points_delta, :decimal, allow_nil?: false
      argument :reward_id, :uuid
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :freeze do
      description "冻结积分卡（active -> frozen）"
      accept []
      change set_attribute(:status, :frozen)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unfreeze do
      description "解冻积分卡（frozen -> active）"
      accept []
      change set_attribute(:status, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :expire_card do
      description "到期处理，清零余额（active -> expired）"
      accept [:expiry_date]
      change set_attribute(:status, :expired)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:points_balance, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_card_number, [:card_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
