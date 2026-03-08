# Workflow: program_lifecycle_flow — 积分计划生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   update --> update
#   update --> activate
#   activate --> pause
#   activate --> expire
#   pause --> activate
#   pause --> expire
#   expire --> [*] : expired
# ```
defmodule UniboV4.Loyalty.LoyaltyProgram do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Loyalty,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboV4.Loyalty.LoyaltyProgram.Notifier]

  resource do
    description "积分计划主体，定义积分获取与消耗规则，支持电商/POS/销售多渠道"
  end

  postgres do
    table "loyalty_programs"
    repo UniboV4.Repo
  end

  graphql do
    type :loyalty_loyalty_program

    queries do
      get :get_loyalty_loyalty_program, :read
      list :list_loyalty_loyalty_programs, :read
    end

    mutations do
      create :create_loyalty_loyalty_program, :create
      update :update_loyalty_loyalty_program, :update
      update :activate_loyalty_loyalty_program, :activate
      update :pause_loyalty_loyalty_program, :pause
      update :expire_loyalty_loyalty_program, :expire
      destroy :delete_loyalty_loyalty_program, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "计划名称（如\"VIP会员积分计划\"）"
    end
    attribute :description, :string do
      public? true
      description "计划说明"
    end
    attribute :program_type, :atom do
      allow_nil? false
      constraints one_of: [:points, :cashback, :discount, :mixed]
      default :points
      public? true
      description "计划类型（积分/现金返还/折扣/混合）"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :active, :paused, :expired]
      default :draft
      public? true
      description "计划状态"
    end
    attribute :points_currency_name, :string do
      default "积分"
      public? true
      description "积分单位名称（积分/里程/金币）"
    end
    attribute :points_per_currency, :decimal do
      default 1.0
      public? true
      description "每消费1元获得的积分数，源自 ProductPromo.billback_factor"
    end
    attribute :require_code, :boolean do
      default false
      public? true
      description "是否需要优惠码才能参与（映射 ProductPromo.require_code）"
    end
    attribute :use_limit_per_order, :integer do
      public? true
      description "每订单最大使用次数（映射 ProductPromo.use_limit_per_order）"
    end
    attribute :use_limit_per_customer, :integer do
      public? true
      description "每客户最大参与次数（映射 ProductPromo.use_limit_per_customer）"
    end
    attribute :use_limit_per_program, :integer do
      public? true
      description "计划全局使用上限（映射 ProductPromo.use_limit_per_promotion）"
    end
    attribute :from_date, :date do
      public? true
      description "计划生效日期"
    end
    attribute :thru_date, :date do
      public? true
      description "计划终止日期"
    end
    attribute :portal_visible, :boolean do
      default true
      public? true
      description "是否在客户门户显示（映射 ProductPromo.show_to_customer）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :rules, UniboV4.Loyalty.LoyaltyRule do
      public? true
      destination_attribute :program_id
    end
    has_many :rewards, UniboV4.Loyalty.LoyaltyReward do
      public? true
      destination_attribute :program_id
    end
    has_many :coupons, UniboV4.Loyalty.Coupon do
      public? true
      destination_attribute :program_id
    end
    has_many :cards, UniboV4.Loyalty.LoyaltyCard do
      public? true
      destination_attribute :program_id
    end
    has_many :translations, UniboV4.Loyalty.LoyaltyProgramTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :program_type, :points_currency_name, :points_per_currency, :require_code, :use_limit_per_order, :use_limit_per_customer, :use_limit_per_program, :from_date, :thru_date, :portal_visible]
      validate present(:name)
      validate present(:program_type)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :program_type, :points_per_currency, :use_limit_per_order, :use_limit_per_customer, :thru_date, :portal_visible]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "激活计划（draft/paused -> active）"
      accept [:from_date]
      change set_attribute(:status, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :pause do
      description "暂停计划（active -> paused）"
      accept []
      change set_attribute(:status, :paused)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :expire do
      description "终止计划（任意 -> expired）"
      accept [:thru_date]
      change set_attribute(:status, :expired)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:points_per_currency, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:rules, :rewards, :coupons, :cards]
  end

end
