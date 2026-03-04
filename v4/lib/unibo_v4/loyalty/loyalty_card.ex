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
defmodule UniboV4.Loyalty.LoyaltyCard do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Loyalty.LoyaltyCard.Notifier]

  postgres do
    table "loyalty_cards"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :card_number, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:active, :frozen, :expired, :cancelled]
      default :active
      public? true
    end
    attribute :points_balance, :decimal do
      allow_nil? false
      default 0
      public? true
    end
    attribute :lifetime_points_earned, :decimal do
      default 0
      public? true
    end
    attribute :expiry_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :points_to_next_tier
  end

  relationships do
    belongs_to :program, UniboV4.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    has_many :transactions, UniboV4.Loyalty.LoyaltyTransaction do
      public? true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :earn_points do
      accept [:points_balance, :lifetime_points_earned]
      argument :points_delta, :decimal, allow_nil?: false
      argument :order_id, :uuid
      argument :reason, :string
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
    update :redeem_points do
      accept [:points_balance]
      argument :points_delta, :decimal, allow_nil?: false
      argument :reward_id, :uuid
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
    update :freeze do
      accept []
      change set_attribute(:status, :frozen)
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
    update :unfreeze do
      accept []
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
    update :expire_card do
      accept [:expiry_date]
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
    validate compare(:points_balance, greater_than_or_equal_to: 0)
    # TODO: 不支持的校验规则 unique
  end

end
