# Workflow: customer_lifecycle — 客户管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> block
#   update --> update
#   update --> block
#   block --> [*]
# ```
defmodule UniboExPoc.Sales.Customer do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "客户主数据（对应 OFBiz PartyGroup + PartyRole CUSTOMER）"
  end

  postgres do
    table "sales_customers"
    repo UniboExPoc.Repo
    identity_index_names unique_customer_code: "idx_sales_customers_unique_customer_code"
  end

  graphql do
    type :sales_customer

    queries do
      get :get_sales_customer, :read
      list :list_sales_customers, :read
      get :get_list_sales_customer, :list
      list :list_list_sales_customers, :list
      get :get_search_sales_customer, :search
      list :list_search_sales_customers, :search
      get :get_get_sales_customer, :get
      list :list_get_sales_customers, :get
      get :get_preview_sales_customer, :preview
      list :list_preview_sales_customers, :preview
      get :get_compute_sales_customer, :compute
      list :list_compute_sales_customers, :compute
      get :get_lookup_sales_customer, :lookup
      list :list_lookup_sales_customers, :lookup
    end

    mutations do
      create :create_sales_customer, :create
      update :update_sales_customer, :update
      update :block_sales_customer, :block
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :customer_code, :string do
      allow_nil? false
      public? true
      description "客户编号"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "客户名称"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive, :blocked]
      default :active
      public? true
    end
    attribute :customer_type, :atom do
      constraints one_of: [:individual, :company]
      default :company
      public? true
    end
    attribute :contact_name, :string, public?: true
    attribute :contact_phone, :string, public?: true
    attribute :contact_email, :string, public?: true
    attribute :billing_address, :string, public?: true
    attribute :shipping_address, :string, public?: true
    attribute :credit_limit, :decimal do
      public? true
      description "信用额度"
    end
    attribute :payment_terms, :string do
      public? true
      description "付款条件"
    end
    attribute :tax_id, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :sales_orders, UniboExPoc.Sales.SalesOrder do
      public? true
    end
    has_many :quotes, UniboExPoc.Sales.Quote do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:customer_code, :name, :customer_type, :contact_name, :contact_phone, :contact_email, :billing_address, :shipping_address, :credit_limit, :payment_terms, :tax_id, :notes]
      validate present(:customer_code)
      validate present(:name)
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
      accept [:name, :contact_name, :contact_phone, :contact_email, :billing_address, :shipping_address, :credit_limit, :payment_terms, :tax_id, :notes, :status]
      # skipped: validate present :name (incompatible with bulk update atomic path)
      require_atomic? false
    end
    update :block do
      description "冻结客户"
      accept []
      # skipped: validate present :name (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态可以冻结"
      change set_attribute(:status, :blocked)
      require_atomic? false
    end
  end

  identities do
    identity :unique_customer_code, [:customer_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
