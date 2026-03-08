# Workflow: rule_lifecycle_flow — 积分规则创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Loyalty.LoyaltyRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "积分规则，定义触发积分奖励的条件（消费阈值、品类、渠道、时间窗口），源自 OFBiz ProductPromoRule + ProductPromoCond"
  end

  postgres do
    table "loyalty_rules"
    repo UniboExPoc.Repo
  end

  graphql do
    type :loyalty_loyalty_rule

    queries do
      get :get_loyalty_loyalty_rule, :read
      list :list_loyalty_loyalty_rules, :read
    end

    mutations do
      create :create_loyalty_loyalty_rule, :create
      update :update_loyalty_loyalty_rule, :update
      destroy :delete_loyalty_loyalty_rule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :rule_name, :string do
      allow_nil? false
      public? true
      description "规则名称（映射 ProductPromoRule.rule_name）"
    end
    attribute :rule_type, :atom do
      allow_nil? false
      constraints one_of: [:min_order_amount, :product_category, :channel, :time_window, :custom]
      public? true
      description "规则类型（最低消费/品类/渠道/时间窗/自定义，映射 ProductPromoCond.input_param_enum_id）"
    end
    attribute :operator, :atom do
      constraints one_of: [:eq, :gt, :gte, :lt, :lte, :in, :not_in]
      default :gte
      public? true
      description "比较运算符（映射 ProductPromoCond.operator_enum_id）"
    end
    attribute :cond_value, :string do
      public? true
      description "条件值（映射 ProductPromoCond.cond_value），如 \"100.00\" 或 \"CATEGORY_A,CATEGORY_B\""
    end
    attribute :other_value, :string do
      public? true
      description "辅助条件值（映射 ProductPromoCond.other_value），如上限金额"
    end
    attribute :points_multiplier, :decimal do
      default 1.0
      public? true
      description "满足条件时的积分倍率（如双倍积分填 2.0）"
    end
    attribute :bonus_points, :decimal do
      default 0
      public? true
      description "满足条件时的固定奖励积分"
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :priority, :integer do
      default 10
      public? true
      description "规则优先级，数字越小越先评估"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :effective_points, :decimal, expr(compute_effective_points(points_multiplier, bonus_points))
  end

  relationships do
    belongs_to :program, UniboExPoc.Loyalty.LoyaltyProgram do
      public? true
      allow_nil? false
    end
    has_many :translations, UniboExPoc.Loyalty.LoyaltyRuleTranslation, public?: true
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
