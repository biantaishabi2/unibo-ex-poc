# Workflow: delivery_carrier_lifecycle — 配送方式管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> rate_shipment
#   create --> destroy
#   update --> update
#   update --> rate_shipment
#   update --> destroy
#   rate_shipment --> update
#   rate_shipment --> rate_shipment
#   destroy --> [*]
# ```
defmodule UniboExPoc.Sales.DeliveryCarrier do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "配送方式/承运商，支持固定价格和基于规则的运费计算"
  end

  postgres do
    table "sales_delivery_carriers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sales_delivery_carrier

    queries do
      get :get_sales_delivery_carrier, :read
      list :list_sales_delivery_carriers, :read
      get :get_list_sales_delivery_carrier, :list
      list :list_list_sales_delivery_carriers, :list
      get :get_search_sales_delivery_carrier, :search
      list :list_search_sales_delivery_carriers, :search
      get :get_get_sales_delivery_carrier, :get
      list :list_get_sales_delivery_carriers, :get
      get :get_preview_sales_delivery_carrier, :preview
      list :list_preview_sales_delivery_carriers, :preview
      get :get_compute_sales_delivery_carrier, :compute
      list :list_compute_sales_delivery_carriers, :compute
      get :get_lookup_sales_delivery_carrier, :lookup
      list :list_lookup_sales_delivery_carriers, :lookup
    end

    mutations do
      create :create_sales_delivery_carrier, :create
      update :update_sales_delivery_carrier, :update
      destroy :delete_sales_delivery_carrier, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "配送方式名称（可翻译）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "活跃状态"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "排序权重"
    end
    attribute :delivery_type, :atom do
      constraints one_of: [:fixed, :base_on_rule]
      default :fixed
      public? true
      description "运费计算方式（固定价格 / 基于规则）"
    end
    attribute :fixed_price, :decimal do
      default 0
      public? true
      description "固定运费金额"
    end
    attribute :free_over, :boolean do
      default false
      public? true
      description "是否启用满额免运费"
    end
    attribute :amount, :decimal do
      default 0
      public? true
      description "满额免运费门槛金额"
    end
    attribute :margin, :decimal do
      default 0
      public? true
      description "运费加成百分比"
    end
    attribute :fixed_margin, :decimal do
      default 0
      public? true
      description "运费固定加成金额"
    end
    attribute :carrier_description, :string do
      public? true
      description "配送方式描述（可翻译）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :price_rules, UniboExPoc.Sales.DeliveryPriceRule do
      public? true
      destination_attribute :carrier_id
    end
    belongs_to :product, UniboExPoc.Sales.Product do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :active, :sequence, :delivery_type, :fixed_price, :free_over, :amount, :margin, :fixed_margin, :carrier_description]
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
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
      accept [:name, :active, :sequence, :delivery_type, :fixed_price, :free_over, :amount, :margin, :fixed_margin, :carrier_description]
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
    action :rate_shipment do
      description "计算订单运费（调用 provider 方法 + 税 + margin + free_over 判断）"
      argument :order_id, :uuid, allow_nil?: false
      run fn input, _context ->
        :ok
      end
    end
  end

  validations do
    validate compare(:fixed_price, greater_than_or_equal_to: 0)
    validate compare(:amount, greater_than_or_equal_to: 0)
    validate compare(:margin, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:price_rules]
  end

end
