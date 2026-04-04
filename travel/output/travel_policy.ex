# Workflow: policy_lifecycle — 差旅政策生命周期：active / inactive
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> deactivate
#   deactivate --> activate
#   activate --> update
#   activate --> deactivate
# ```
defmodule Travel.Travel.TravelPolicy do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: Travel.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "差旅标准政策，定义不同企业、职级、城市等级下的差旅费用上限与超标策略"
  end

  postgres do
    table "travel_policies"
    repo Travel.Repo
    identity_index_names unique_policy_scope: "idx_travel_policies_unique_policy_scope"
  end

  graphql do
    type :travel_travel_policy

    queries do
      get :get_travel_travel_policy, :read
      list :list_travel_travel_policys, :read
      list :list_match_policy_travel_travel_policys, :match_policy
    end

    mutations do
      create :create_travel_travel_policy, :create
      update :update_travel_travel_policy, :update
      update :activate_travel_travel_policy, :activate
      update :deactivate_travel_travel_policy, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :policy_name, :string do
      allow_nil? false
      public? true
      description "政策名称，如\"总部差旅标准\""
    end
    attribute :product_type, :atom do
      allow_nil? false
      constraints one_of: [:flight, :hotel, :train, :car]
      public? true
      description "适用商品类型"
    end
    attribute :employee_level, :string do
      public? true
      description "职级标识"
    end
    attribute :city_tier, :string do
      public? true
      description "城市等级（tier_1/tier_2/tier_3）"
    end
    attribute :season, :string do
      public? true
      description "淡旺季标识（可选）"
    end
    attribute :max_amount, :integer do
      public? true
      description "金额上限（单位分）"
    end
    attribute :cabin_class_limit, :string do
      public? true
      description "舱位限制"
    end
    attribute :hotel_star_limit, :string do
      public? true
      description "酒店星级限制"
    end
    attribute :exceed_strategy, :atom do
      allow_nil? false
      constraints one_of: [:block, :require_reason, :require_approval, :personal_pay]
      public? true
      description "超标处理策略"
    end
    attribute :approval_mode, :atom do
      constraints one_of: [:none, :self, :oa]
      default :self
      public? true
      description "审批模式；none 表示关闭审批，self/oa 表示进入对应审批流"
    end
    attribute :personal_pay_ratio, :integer do
      public? true
      description "个人支付比例 0-100"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :enterprise_id, :string do
      public? true
      description "企业标识（不做跨域外键）"
    end
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Policy via Create. doc_url: graphql://contract/travel/create_travel_travel_policy"
      primary? true
      accept [:policy_name, :product_type, :employee_level, :city_tier, :season, :max_amount, :cabin_class_limit, :hotel_star_limit, :exceed_strategy, :approval_mode, :personal_pay_ratio, :enterprise_id]
      validate present(:policy_name)
      validate present(:product_type)
      validate present(:exceed_strategy)
    end
    update :update do
      description "Update Travel Policy via Update. doc_url: graphql://contract/travel/update_travel_travel_policy"
      primary? true
      accept [:policy_name, :season, :max_amount, :cabin_class_limit, :hotel_star_limit, :exceed_strategy, :approval_mode, :personal_pay_ratio]
      require_atomic? false
    end
    read :match_policy do
      argument :product_type, :string, allow_nil?: false
      argument :employee_level, :string
      argument :city_tier, :string
      filter expr(is_active == true and product_type == ^arg(:product_type))
      prepare fn query, _ctx ->
        query = Ash.Query.sort(query, [:employee_level, :city_tier])
        query = Ash.Query.limit(query, 1)
        query
      end
    end
    update :activate do
      description "Update Travel Policy via Activate. doc_url: graphql://contract/travel/activate_travel_travel_policy"
      accept [:is_active]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有未启用的政策可以激活"
      change set_attribute(:is_active, true)
      require_atomic? false
    end
    update :deactivate do
      description "Update Travel Policy via Deactivate. doc_url: graphql://contract/travel/deactivate_travel_travel_policy"
      accept [:is_active]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有已启用的政策可以停用"
      change set_attribute(:is_active, false)
      require_atomic? false
    end
  end

  validations do
    validate compare(:personal_pay_ratio, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

  identities do
    identity :unique_policy_scope, [:policy_name, :product_type, :employee_level, :city_tier]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    belongs_to_actor :user, Travel.Accounts.User, allow_nil?: true
    ignore_attributes [:inserted_at, :updated_at]
  end


  pub_sub do
    module Travel.PubSub
    prefix "travel_policy"

    publish :activate, ["travel.policy.activated"]
    publish :deactivate, ["travel.policy.deactivated"]
  end
end
