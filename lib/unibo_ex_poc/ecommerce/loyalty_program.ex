# Workflow: loyalty_program_lifecycle — 忠诚度计划管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.LoyaltyProgram do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "积分/优惠券/忠诚度计划"
  end

  postgres do
    table "ecommerce_loyalty_programs"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_loyalty_program

    queries do
      get :get_ecommerce_loyalty_program, :read
      list :list_ecommerce_loyalty_programs, :read
    end

    mutations do
      create :create_ecommerce_loyalty_program, :create
      update :update_ecommerce_loyalty_program, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "计划名称"
    end
    attribute :program_type, :atom do
      constraints one_of: [:coupon, :loyalty, :promotion, :gift_card, :ewallet]
      default :loyalty
      public? true
      description "计划类型"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :sale_ok, :boolean do
      default true
      public? true
      description "是否在 POS/销售中可用"
    end
    attribute :ecommerce_ok, :boolean do
      default true
      public? true
      description "是否在电商网站可用"
    end
    attribute :trigger, :atom do
      constraints one_of: [:auto, :with_code]
      default :auto
      public? true
      description "触发方式（自动/输入促销码）"
    end
    attribute :applies_on, :atom do
      constraints one_of: [:current, :future, :both]
      default :current
      public? true
      description "适用于当前订单/未来订单/两者"
    end
    attribute :date_from, :date do
      public? true
      description "有效期起始"
    end
    attribute :date_to, :date do
      public? true
      description "有效期结束"
    end
    attribute :limit_usage, :boolean do
      default false
      public? true
      description "是否限制总使用次数"
    end
    attribute :max_usage, :integer do
      public? true
      description "最大使用次数（limit_usage=true 时生效）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :rules, UniboV4.Ecommerce.LoyaltyRule do
      public? true
      source_attribute :website_id
      destination_attribute :program_id
    end
    has_many :rewards, UniboV4.Ecommerce.LoyaltyReward do
      public? true
      source_attribute :website_id
      destination_attribute :program_id
    end
    has_many :cards, UniboV4.Ecommerce.LoyaltyCard do
      public? true
      source_attribute :website_id
      destination_attribute :program_id
    end
    belongs_to :website, UniboV4.Ecommerce.WebSite do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :program_type, :active, :sale_ok, :ecommerce_ok, :trigger, :applies_on, :date_from, :date_to, :limit_usage, :max_usage]
      argument :website_id, :uuid
      validate present(:name)
      # validation: max_usage_required_when_limited
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :program_type, :active, :sale_ok, :ecommerce_ok, :trigger, :applies_on, :date_from, :date_to, :limit_usage, :max_usage]
      argument :website_id, :uuid
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_loyalty_program_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
