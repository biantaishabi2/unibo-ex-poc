# Workflow: order_line_editing — 采购订单行编辑流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Purchasing.PurchaseOrderLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_purchase_order_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_purchase_order_line

    queries do
      get :get_purchasing_purchase_order_line, :read
      list :list_purchasing_purchase_order_lines, :read
      get :get_list_purchasing_purchase_order_line, :list
      list :list_list_purchasing_purchase_order_lines, :list
      get :get_search_purchasing_purchase_order_line, :search
      list :list_search_purchasing_purchase_order_lines, :search
      get :get_get_purchasing_purchase_order_line, :get
      list :list_get_purchasing_purchase_order_lines, :get
      get :get_preview_purchasing_purchase_order_line, :preview
      list :list_preview_purchasing_purchase_order_lines, :preview
      get :get_compute_purchasing_purchase_order_line, :compute
      list :list_compute_purchasing_purchase_order_lines, :compute
      get :get_lookup_purchasing_purchase_order_line, :lookup
      list :list_lookup_purchasing_purchase_order_lines, :lookup
    end

    mutations do
      create :create_purchasing_purchase_order_line, :create
      update :update_purchasing_purchase_order_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_id, :uuid, public?: true
    attribute :product_uom_id, :uuid, public?: true
    attribute :product_packaging_id, :uuid, public?: true
    attribute :product_packaging_qty, :decimal, public?: true
    attribute :price_unit, :decimal do
      allow_nil? false
      public? true
    end
    attribute :discount, :decimal do
      default 0
      public? true
    end
    attribute :date_planned, :utc_datetime, public?: true
    attribute :qty_received_method, :atom do
      constraints one_of: [:manual, :stock_move]
      public? true
    end
    attribute :qty_received_manual, :decimal, public?: true
    attribute :taxes_id, :map, public?: true
    attribute :analytic_distribution, :map, public?: true
    attribute :display_type, :atom do
      constraints one_of: [false, :line_section, :line_note]
      default false
      public? true
    end
    attribute :company_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :price_unit_discounted
    # TODO: 不支持的 calculation 表达式 :price_subtotal
    # TODO: 不支持的 calculation 表达式 :price_total
    # TODO: 不支持的 calculation 表达式 :price_tax
    # TODO: 不支持的 calculation 表达式 :qty_received
    # TODO: 不支持的 calculation 表达式 :qty_invoiced
    # TODO: 不支持的 calculation 表达式 :qty_to_invoice
    # TODO: 不支持的 calculation 表达式 :product_qty
  end

  relationships do
    belongs_to :order, UniboV4.Purchasing.PurchaseOrder do
      public? true
      allow_nil? false
    end
    has_many :invoice_lines, UniboV4.Purchasing.AccountMoveLine do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :product_id, :product_uom_id, :product_packaging_id, :product_packaging_qty, :price_unit, :discount, :date_planned, :taxes_id, :analytic_distribution, :display_type, :qty_received_manual]
      argument :product_qty, :decimal
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的表达式类型
      # TODO: 不支持的表达式类型
      # TODO: 不支持的表达式类型
      # TODO: 不支持的表达式类型
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
      accept [:price_unit, :discount, :date_planned, :taxes_id, :analytic_distribution, :qty_received_manual]
      argument :product_qty, :decimal
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的表达式类型
      # TODO: 不支持的表达式类型
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
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
  end

  validations do
    validate compare(:product_qty, greater_than: 0)
    validate compare(:price_unit, greater_than_or_equal_to: 0)
  end

end
