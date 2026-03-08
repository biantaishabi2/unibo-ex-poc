# Workflow: price_rule_lifecycle — 运费规则管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Sales.DeliveryPriceRule do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "配送运费计算规则，基于重量/体积/价格/数量条件匹配并计算运费"
  end

  postgres do
    table "sales_delivery_price_rules"
    repo UniboV4.Repo
  end

  graphql do
    type :sales_delivery_price_rule

    queries do
      get :get_sales_delivery_price_rule, :read
      list :list_sales_delivery_price_rules, :read
      get :get_list_sales_delivery_price_rule, :list
      list :list_list_sales_delivery_price_rules, :list
      get :get_search_sales_delivery_price_rule, :search
      list :list_search_sales_delivery_price_rules, :search
      get :get_get_sales_delivery_price_rule, :get
      list :list_get_sales_delivery_price_rules, :get
      get :get_preview_sales_delivery_price_rule, :preview
      list :list_preview_sales_delivery_price_rules, :preview
      get :get_compute_sales_delivery_price_rule, :compute
      list :list_compute_sales_delivery_price_rules, :compute
      get :get_lookup_sales_delivery_price_rule, :lookup
      list :list_lookup_sales_delivery_price_rules, :lookup
    end

    mutations do
      create :create_sales_delivery_price_rule, :create
      update :update_sales_delivery_price_rule, :update
      destroy :delete_sales_delivery_price_rule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sequence, :integer do
      default 10
      public? true
      description "规则匹配优先级"
    end
    attribute :variable, :atom do
      allow_nil? false
      constraints one_of: [:weight, :volume, :wv, :price, :quantity]
      public? true
      description "条件变量（重量/体积/重量*体积/价格/数量）"
    end
    attribute :operator, :atom do
      allow_nil? false
      constraints one_of: [:"==", :"<=", :"<", :">=", :">"]
      public? true
      description "比较运算符"
    end
    attribute :max_value, :decimal do
      default 0
      public? true
      description "条件阈值"
    end
    attribute :list_base_price, :decimal do
      default 0
      public? true
      description "基础运费"
    end
    attribute :list_price, :decimal do
      default 0
      public? true
      description "每单位变量的附加费"
    end
    attribute :variable_factor, :atom do
      allow_nil? false
      constraints one_of: [:weight, :volume, :wv, :price, :quantity]
      public? true
      description "附加费的计算因子"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :carrier, UniboV4.Sales.DeliveryCarrier do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:sequence, :variable, :operator, :max_value, :list_base_price, :list_price, :variable_factor]
      argument :carrier_id, :uuid, allow_nil?: false
      change manage_relationship(:carrier_id, :carrier, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    read :list do
      description "列表查询"
    end
    read :search do
      description "条件检索"
    end
    read :get do
      description "详情查询"
    end
    read :preview do
      description "预览查询"
    end
    read :compute do
      description "计算查询"
    end
    read :lookup do
      description "快速检索"
    end
    update :update do
      primary? true
      accept [:sequence, :variable, :operator, :max_value, :list_base_price, :list_price, :variable_factor]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:max_value, greater_than_or_equal_to: 0)
    validate compare(:list_base_price, greater_than_or_equal_to: 0)
    validate compare(:list_price, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
