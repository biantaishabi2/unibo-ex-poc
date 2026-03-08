# Workflow: transaction_flow — 积分流水创建与撤销流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> cancel_transaction
#   cancel_transaction --> [*] : cancelled
# ```
defmodule UniboExPoc.Loyalty.LoyaltyTransaction do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Loyalty.LoyaltyTransaction.Notifier]

  resource do
    description "积分流水，记录积分的每次变动（获取/消耗/过期/退款），是积分生命周期的审计日志"
  end

  postgres do
    table "loyalty_transactions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :loyalty_loyalty_transaction

    queries do
      get :get_loyalty_loyalty_transaction, :read
      list :list_loyalty_loyalty_transactions, :read
    end

    mutations do
      create :create_loyalty_loyalty_transaction, :create
      update :cancel_transaction_loyalty_loyalty_transaction, :cancel_transaction
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :transaction_type, :atom do
      allow_nil? false
      constraints one_of: [:earned, :redeemed, :expired, :refunded, :adjusted, :transferred]
      public? true
      description "流水类型（获取/消耗/过期/退款/人工调整/转移）"
    end
    attribute :points_delta, :decimal do
      allow_nil? false
      public? true
      description "积分变动量（正数=增加，负数=减少；扩展 ProductPromoUse.total_discount_amount）"
    end
    attribute :balance_after, :decimal do
      allow_nil? false
      public? true
      description "本次操作后的积分余额快照"
    end
    attribute :lifecycle_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :confirmed, :cancelled]
      default :confirmed
      public? true
      description "流水状态（pending=待确认，confirmed=已确认，cancelled=已撤销）"
    end
    attribute :reference_type, :string do
      public? true
      description "关联业务类型（order/return/admin_adjustment）"
    end
    attribute :reference_id, :string do
      public? true
      description "关联业务 ID（映射 ProductPromoUse.order_id）"
    end
    attribute :promo_code_used, :string do
      public? true
      description "使用的优惠码（映射 ProductPromoUse.product_promo_code_id）"
    end
    attribute :note, :string do
      public? true
      description "备注说明"
    end
    attribute :expires_at, :utc_datetime do
      public? true
      description "本批次积分的过期时间（earned 类型专用）"
    end
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :card, UniboExPoc.Loyalty.LoyaltyCard do
      public? true
      allow_nil? false
    end
    belongs_to :reward, UniboExPoc.Loyalty.LoyaltyReward do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:transaction_type, :points_delta, :balance_after, :reference_type, :reference_id, :promo_code_used, :note, :expires_at]
      argument :card_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
      argument :reward_id, :uuid
      change manage_relationship(:card_id, :card, type: :append, on_lookup: :relate)
      validate present(:points_delta)
      validate present(:transaction_type)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :cancel_transaction do
      description "撤销流水（confirmed -> cancelled），同步回滚积分卡余额"
      primary? true
      accept [:note]
      change set_attribute(:lifecycle_status, :cancelled)
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

end
