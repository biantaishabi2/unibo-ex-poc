# Workflow: transaction_flow — 积分流水创建与撤销流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> cancel_transaction
#   cancel_transaction --> [*] : cancelled
# ```
defmodule UniboV4.Loyalty.LoyaltyTransaction do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Loyalty.LoyaltyTransaction.Notifier]

  postgres do
    table "loyalty_transactions"
    repo UniboV4.Repo
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
    end
    attribute :points_delta, :decimal do
      allow_nil? false
      public? true
    end
    attribute :balance_after, :decimal do
      allow_nil? false
      public? true
    end
    attribute :lifecycle_status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :confirmed, :cancelled]
      default :confirmed
      public? true
    end
    attribute :reference_type, :string, public?: true
    attribute :reference_id, :string, public?: true
    attribute :promo_code_used, :string, public?: true
    attribute :note, :string, public?: true
    attribute :expires_at, :utc_datetime, public?: true
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :card, UniboV4.Loyalty.LoyaltyCard do
      public? true
      allow_nil? false
    end
    belongs_to :reward, UniboV4.Loyalty.LoyaltyReward do
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

end
