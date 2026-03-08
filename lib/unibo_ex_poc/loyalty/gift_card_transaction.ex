# Workflow: giftcard_transaction_flow — 礼品卡流水写入流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Loyalty.GiftCardTransaction do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "礼品卡充值与消费流水，支持审计和退款追溯"
  end

  postgres do
    table "loyalty_gift_card_transactions"
    repo UniboV4.Repo
  end

  graphql do
    type :loyalty_gift_card_transaction

    queries do
      get :get_loyalty_gift_card_transaction, :read
      list :list_loyalty_gift_card_transactions, :read
    end

    mutations do
      create :create_loyalty_gift_card_transaction, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :transaction_type, :atom do
      allow_nil? false
      constraints one_of: [:topup, :charge, :refund, :expired_deduction]
      public? true
      description "流水类型（充值/消费/退款/到期扣减）"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "变动金额（正=充值，负=消费）"
    end
    attribute :balance_after, :decimal do
      allow_nil? false
      public? true
      description "操作后余额快照"
    end
    attribute :reference_id, :string do
      public? true
      description "关联业务 ID（订单/支付单）"
    end
    attribute :note, :string, public?: true
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :gift_card, UniboV4.Loyalty.GiftCard do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:transaction_type, :amount, :balance_after, :reference_id, :note]
      argument :gift_card_id, :uuid, allow_nil?: false
      argument :operator_id, :uuid
      change manage_relationship(:gift_card_id, :gift_card, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
  end

end
