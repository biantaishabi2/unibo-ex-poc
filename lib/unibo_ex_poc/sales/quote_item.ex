# Workflow: quote_item_editing — 报价明细编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Sales.QuoteItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "报价单明细行（对齐 OFBiz QuoteItem）"
  end

  postgres do
    table "sales_quote_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :sales_quote_item

    mutations do
      create :create_sales_quote_item, :create
      update :update_sales_quote_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "数量（对齐 OFBiz quantity，类型从 integer 改为 decimal）"
    end
    attribute :quote_unit_price, :decimal do
      allow_nil? false
      public? true
      description "报价单价（对齐 OFBiz quote_unit_price）"
    end
    attribute :estimated_delivery_date, :utc_datetime do
      public? true
      description "预计交付日（对齐 OFBiz estimated_delivery_date）"
    end
    attribute :comments, :string do
      public? true
      description "备注（对齐 OFBiz comments）"
    end
    attribute :seq_id, :integer do
      public? true
      description "行序号（对齐 OFBiz quote_item_seq_id）"
    end
    attribute :is_promo, :boolean do
      default false
      public? true
      description "是否促销项（对齐 OFBiz is_promo）"
    end
    attribute :lead_time_days, :integer do
      public? true
      description "交付提前期天数（对齐 OFBiz lead_time_days）"
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
      description "产品名称（业务扩展，OFBiz 通过 product_id 关联）"
    end
    attribute :product_code, :string do
      public? true
      description "产品编码（业务扩展）"
    end
    attribute :line_amount, :decimal do
      allow_nil? false
      public? true
      description "行金额（computed = quantity * quote_unit_price）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :quote, UniboExPoc.Sales.Quote do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_name, :product_code, :quantity, :quote_unit_price, :comments, :estimated_delivery_date, :seq_id, :is_promo, :lead_time_days]
      argument :quote_id, :uuid, allow_nil?: false
      change manage_relationship(:quote_id, :quote, type: :append, on_lookup: :relate)
      change set_attribute(:line_amount, expr((quantity * quote_unit_price)))
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :quote_unit_price, :comments, :estimated_delivery_date, :seq_id, :is_promo, :lead_time_days]
      change set_attribute(:line_amount, expr((quantity * quote_unit_price)))
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
    validate compare(:quote_unit_price, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
