# Workflow: invoice_item_editing — 发票明细行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboExPoc.Accounting.InvoiceItem do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "发票明细行（对齐 OFBiz InvoiceItem）"
  end

  postgres do
    table "accounting_invoice_items"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_invoice_item

    mutations do
      create :create_accounting_invoice_item, :create
      update :update_accounting_invoice_item, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_item_type_id, :string do
      public? true
      description "发票行类型（对齐 OFBiz InvoiceItemType，如 产品/服务/税/折扣）"
    end
    attribute :seq_id, :integer do
      public? true
      description "行序号（对齐 OFBiz invoice_item_seq_id）"
    end
    attribute :description, :string do
      allow_nil? false
      public? true
      description "行描述（对齐 OFBiz description）"
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
      description "数量（对齐 OFBiz quantity，类型从 integer 改为 decimal）"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "单价/行金额（对齐 OFBiz amount）"
    end
    attribute :taxable_flag, :boolean do
      default true
      public? true
      description "是否应税（对齐 OFBiz taxable_flag）"
    end
    attribute :tax_auth_party_id, :string do
      public? true
      description "税务机关方（对齐 OFBiz tax_auth_party_id）"
    end
    attribute :tax_auth_geo_id, :string do
      public? true
      description "税务地区（对齐 OFBiz tax_auth_geo_id）"
    end
    attribute :product_id, :string do
      public? true
      description "产品引用（对齐 OFBiz product_id）"
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
      description "单价（业务扩展，OFBiz 用 amount 表示单行金额）"
    end
    attribute :tax_rate, :decimal do
      default 0
      public? true
      description "税率百分比（业务扩展，OFBiz 通过 TaxAuthorityRateProduct 引用）"
    end
    attribute :tax_amount, :decimal do
      default 0
      public? true
      description "税额（computed，业务扩展）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :invoice, UniboExPoc.Accounting.Invoice do
      public? true
      allow_nil? false
    end
    belongs_to :gl_account, UniboExPoc.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:description, :quantity, :unit_price, :tax_rate, :taxable_flag, :invoice_item_type_id, :seq_id, :product_id, :tax_auth_party_id, :tax_auth_geo_id]
      argument :gl_account_id, :uuid
      argument :invoice_id, :uuid, allow_nil?: false
      change manage_relationship(:invoice_id, :invoice, type: :append, on_lookup: :relate)
      validate compare(:quantity, greater_than: 0)
      # message: "数量必须大于零"
      validate compare(:unit_price, greater_than_or_equal_to: 0)
      change set_attribute(:amount, expr((quantity * unit_price)))
      change set_attribute(:tax_amount, expr(((amount * tax_rate) / 100)))
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:quantity, :unit_price, :tax_rate, :taxable_flag, :invoice_item_type_id, :seq_id, :product_id]
      # skipped: validate compare :quantity (incompatible with bulk update atomic path)
      # skipped: validate compare :unit_price (incompatible with bulk update atomic path)
      change set_attribute(:amount, expr((quantity * unit_price)))
      change set_attribute(:tax_amount, expr(((amount * tax_rate) / 100)))
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
