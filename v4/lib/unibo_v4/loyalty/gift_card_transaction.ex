# Workflow: giftcard_transaction_flow — 礼品卡流水写入流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Loyalty.Loyalty.GiftCardTransaction do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :balance_after, :decimal do
      allow_nil? false
      public? true
    end
    attribute :reference_id, :string, public?: true
    attribute :note, :string, public?: true
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :gift_card, UniboV4.Loyalty.Loyalty.GiftCard do
      public? true
      allow_nil? false
    end
    belongs_to :operator, UniboV4.Loyalty.Loyalty.ResUser do
      public? true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
