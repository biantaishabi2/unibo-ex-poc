# Workflow: reward_lifecycle — 积分奖励管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Ecommerce.LoyaltyReward do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "积分奖励定义（折扣/免费产品/免运费等）"
  end

  postgres do
    table "ecommerce_loyalty_rewards"
    repo UniboExPoc.Repo
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
    attribute :reward_type, :atom do
      constraints one_of: [:discount, :product, :free_shipping]
      default :discount
      public? true
      description "奖励类型"
    end
    attribute :discount, :decimal do
      public? true
      description "折扣值"
    end
    attribute :discount_mode, :atom do
      constraints one_of: [:percent, :per_point, :per_order]
      default :percent
      public? true
      description "折扣模式"
    end
    attribute :discount_max_amount, :decimal do
      public? true
      description "最大折扣金额上限"
    end
    attribute :required_points, :decimal do
      default 1
      public? true
      description "兑换所需积分"
    end
    attribute :description, :string do
      public? true
      description "奖励描述"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :program, UniboExPoc.Ecommerce.LoyaltyProgram do
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
