# Workflow: reward_lifecycle — 积分奖励管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.LoyaltyReward do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_loyalty_rewards"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_loyalty_reward

    queries do
      get :get_ecommerce_loyalty_reward, :read
      list :list_ecommerce_loyalty_rewards, :read
    end

    mutations do
      create :create_ecommerce_loyalty_reward, :create
      update :update_ecommerce_loyalty_reward, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :program_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :reward_type, :atom do
      constraints one_of: [:discount, :product, :free_shipping]
      default :discount
      public? true
    end
    attribute :discount, :decimal, public?: true
    attribute :discount_mode, :atom do
      constraints one_of: [:percent, :per_point, :per_order]
      default :percent
      public? true
    end
    attribute :discount_max_amount, :decimal, public?: true
    attribute :required_points, :decimal do
      default 1
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :program, UniboV4.Ecommerce.LoyaltyProgram do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:reward_type, :discount, :discount_mode, :discount_max_amount, :required_points, :description]
      argument :program_id, :uuid, allow_nil?: false
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
      validate compare(:discount, greater_than_or_equal_to: 0)
      # message: "折扣值不能为负"
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
      accept [:reward_type, :discount, :discount_mode, :discount_max_amount, :required_points, :description]
      # skipped: validate compare :discount (incompatible with bulk update atomic path)
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
    validate compare(:required_points, greater_than: 0)
  end

end
