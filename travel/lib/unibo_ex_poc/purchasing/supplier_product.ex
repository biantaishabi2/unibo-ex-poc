# Workflow: supplier_product_lifecycle — 供应商产品管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Purchasing.SupplierProduct do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "供应商产品价格目录"
  end

  postgres do
    table "purchasing_supplier_products"
    repo UniboExPoc.Repo
  end

  graphql do
    type :purchasing_supplier_product

    queries do
      get :get_purchasing_supplier_product, :read
      list :list_purchasing_supplier_products, :read
      get :get_list_purchasing_supplier_product, :list
      list :list_list_purchasing_supplier_products, :list
      get :get_search_purchasing_supplier_product, :search
      list :list_search_purchasing_supplier_products, :search
      get :get_get_purchasing_supplier_product, :get
      list :list_get_purchasing_supplier_products, :get
      get :get_preview_purchasing_supplier_product, :preview
      list :list_preview_purchasing_supplier_products, :preview
      get :get_compute_purchasing_supplier_product, :compute
      list :list_compute_purchasing_supplier_products, :compute
      get :get_lookup_purchasing_supplier_product, :lookup
      list :list_lookup_purchasing_supplier_products, :lookup
    end

    mutations do
      create :create_purchasing_supplier_product, :create
      update :update_purchasing_supplier_product, :update
      destroy :delete_purchasing_supplier_product, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string do
      public? true
      description "产品编号/SKU"
    end
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
      description "单价"
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :min_order_quantity, :integer do
      default 1
      public? true
      description "最小起订量"
    end
    attribute :lead_time_days, :integer do
      public? true
      description "交货周期（天）"
    end
    attribute :available_from, :date, public?: true
    attribute :available_thru, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :supplier, UniboExPoc.Purchasing.Supplier do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:product_name, :product_code, :unit_price, :currency, :min_order_quantity, :lead_time_days, :available_from, :available_thru]
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:unit_price, :currency, :min_order_quantity, :lead_time_days, :available_from, :available_thru]
      change set_attribute(:id, expr(id))
      require_atomic? false
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
  end

  validations do
    validate compare(:unit_price, greater_than_or_equal_to: 0)
    validate compare(:min_order_quantity, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
