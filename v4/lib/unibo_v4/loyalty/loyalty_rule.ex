# Workflow: rule_lifecycle_flow — 积分规则创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Loyalty.LoyaltyRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Loyalty,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "loyalty_rules"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :rule_name, :string do
      allow_nil? false
      public? true
    end
    attribute :rule_type, :atom do
      allow_nil? false
      constraints one_of: [:min_order_amount, :product_category, :channel, :time_window, :custom]
      public? true
    end
    attribute :operator, :atom do
      constraints one_of: [:eq, :gt, :gte, :lt, :lte, :in, :not_in]
      default :gte
      public? true
    end
    attribute :cond_value, :string, public?: true
    attribute :other_value, :string, public?: true
    attribute :points_multiplier, :decimal do
      default 1.0
      public? true
    end
    attribute :bonus_points, :decimal do
      default 0
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :priority, :integer do
      default 10
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :effective_points
  end

  relationships do
    belongs_to :program, UniboV4.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboV4.Loyalty.LoyaltyRuleTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:rule_name, :rule_type, :operator, :cond_value, :other_value, :points_multiplier, :bonus_points, :active, :priority]
      argument :program_id, :uuid, allow_nil?: false
      change manage_relationship(:program_id, :program, type: :append, on_lookup: :relate)
      validate present(:rule_name)
      validate present(:cond_value)
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
      accept [:rule_name, :cond_value, :other_value, :points_multiplier, :bonus_points, :active, :priority]
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
    validate compare(:points_multiplier, greater_than: 0)
  end

end
