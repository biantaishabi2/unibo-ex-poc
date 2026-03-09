# Workflow: reward_lifecycle_flow — 奖励动作创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Loyalty.LoyaltyReward do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "积分奖励动作，定义满足规则后触发的奖励内容（折扣、赠品、积分抵扣），源自 OFBiz ProductPromoAction"
  end

  postgres do
    table "loyalty_rewards"
    repo UniboExPoc.Repo
  end

  graphql do
    type :loyalty_loyalty_reward

    queries do
      get :get_loyalty_loyalty_reward, :read
      list :list_loyalty_loyalty_rewards, :read
    end

    mutations do
      create :create_loyalty_loyalty_reward, :create
      update :update_loyalty_loyalty_reward, :update
      destroy :delete_loyalty_loyalty_reward, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :reward_name, :string do
      allow_nil? false
      public? true
      description "奖励名称"
    end
    attribute :reward_type, :atom do
      allow_nil? false
      constraints one_of: [:discount_percent, :discount_fixed, :free_product, :points_grant, :gift_card_topup]
      public? true
      description "奖励类型（百分比折扣/固定折扣/赠品/积分赠送/礼品卡充值，映射 ProductPromoAction.product_promo_action_enum_id）"
    end
    attribute :discount_percent, :decimal do
      public? true
      description "折扣百分比（reward_type=discount_percent 时有效，映射 ProductPromoAction.quantity）"
    end
    attribute :discount_amount, :decimal do
      public? true
      description "固定折扣金额（reward_type=discount_fixed 时有效，映射 ProductPromoAction.amount）"
    end
    attribute :points_cost, :decimal do
      default 0
      public? true
      description "兑换本奖励需消耗的积分数（0 表示无需消耗积分）"
    end
    attribute :points_grant, :decimal do
      default 0
      public? true
      description "本奖励额外赠送的积分数"
    end
    attribute :gift_card_amount, :decimal do
      public? true
      description "礼品卡充值金额（reward_type=gift_card_topup 时有效）"
    end
    attribute :use_cart_quantity, :boolean do
      default false
      public? true
      description "是否按购物车数量重复应用（映射 ProductPromoAction.use_cart_quantity）"
    end
    attribute :max_discount, :decimal do
      public? true
      description "单次最大折扣上限（防止超额优惠）"
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :program, UniboExPoc.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboExPoc.Loyalty.LoyaltyRewardTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:reward_name, :reward_type, :discount_percent, :discount_amount, :points_cost, :points_grant, :gift_card_amount, :use_cart_quantity, :max_discount, :active]
      argument :program_id, :uuid, allow_nil?: false
      argument :free_product_id, :uuid
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
      validate present(:reward_name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:reward_name, :discount_percent, :discount_amount, :points_cost, :max_discount, :active]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
