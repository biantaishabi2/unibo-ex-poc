# Workflow: rule_lifecycle — 积分规则管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Ecommerce.LoyaltyRule do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "积分规则（满足条件获得积分/优惠）"
  end

  postgres do
    table "ecommerce_loyalty_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_loyalty_rule

    queries do
      get :get_ecommerce_loyalty_rule, :read
      list :list_ecommerce_loyalty_rules, :read
    end

    mutations do
      create :create_ecommerce_loyalty_rule, :create
      update :update_ecommerce_loyalty_rule, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      public? true
      description "促销码（trigger=with_code 时使用）"
    end
    attribute :minimum_qty, :integer do
      default 0
      public? true
      description "最低购买数量"
    end
    attribute :minimum_amount, :decimal do
      default 0
      public? true
      description "最低消费金额"
    end
    attribute :reward_point_amount, :decimal do
      default 1
      public? true
      description "满足条件后奖励积分数"
    end
    attribute :reward_point_mode, :atom do
      constraints one_of: [:order, :money, :unit]
      default :order
      public? true
      description "积分计算方式（按单/按金额/按数量）"
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
      accept [:code, :minimum_qty, :minimum_amount, :reward_point_amount, :reward_point_mode]
      argument :program_id, :uuid, allow_nil?: false
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
      # NOTE: unique 校验缺少 field
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
      accept [:code, :minimum_qty, :minimum_amount, :reward_point_amount, :reward_point_mode]
      # skipped: validate unique : (incompatible with bulk update atomic path)
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
