# Workflow: reward_lifecycle_flow — 奖励动作创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Loyalty.Loyalty.LoyaltyReward do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "loyalty_rewards"
    repo UniboV4.Repo
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
    end
    attribute :reward_type, :atom do
      allow_nil? false
      constraints one_of: [:discount_percent, :discount_fixed, :free_product, :points_grant, :gift_card_topup]
      public? true
    end
    attribute :discount_percent, :decimal, public?: true
    attribute :discount_amount, :decimal, public?: true
    attribute :points_cost, :decimal do
      default 0
      public? true
    end
    attribute :points_grant, :decimal do
      default 0
      public? true
    end
    attribute :gift_card_amount, :decimal, public?: true
    attribute :use_cart_quantity, :boolean do
      default false
      public? true
    end
    attribute :max_discount, :decimal, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :program, UniboV4.Loyalty.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    belongs_to :free_product, UniboV4.Loyalty.Loyalty.ProductTemplate do
      public? true
    end
    has_many :translations, UniboV4.Loyalty.Loyalty.LoyaltyRewardTranslation, public?: true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:reward_name, :discount_percent, :discount_amount, :points_cost, :max_discount, :active]
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
