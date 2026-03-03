# Workflow: supplierinfo_lifecycle — 供应商报价记录管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Purchasing.ProductSupplierinfo do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Purchasing.ProductSupplierinfo.Notifier]

  postgres do
    table "purchasing_product_supplierinfos"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_product_supplierinfo

    queries do
      get :get_purchasing_product_supplierinfo, :read
      list :list_purchasing_product_supplierinfos, :read
      get :get_list_purchasing_product_supplierinfo, :list
      list :list_list_purchasing_product_supplierinfos, :list
      get :get_search_purchasing_product_supplierinfo, :search
      list :list_search_purchasing_product_supplierinfos, :search
      get :get_get_purchasing_product_supplierinfo, :get
      list :list_get_purchasing_product_supplierinfos, :get
      get :get_preview_purchasing_product_supplierinfo, :preview
      list :list_preview_purchasing_product_supplierinfos, :preview
      get :get_compute_purchasing_product_supplierinfo, :compute
      list :list_compute_purchasing_product_supplierinfos, :compute
      get :get_lookup_purchasing_product_supplierinfo, :lookup
      list :list_lookup_purchasing_product_supplierinfos, :lookup
    end

    mutations do
      create :create_purchasing_product_supplierinfo, :create
      update :update_purchasing_product_supplierinfo, :update
      destroy :delete_purchasing_product_supplierinfo, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :partner_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :product_id, :uuid, public?: true
    attribute :available_from_date, :date, public?: true
    attribute :available_thru_date, :date, public?: true
    attribute :minimum_order_quantity, :decimal do
      default 0
      public? true
    end
    attribute :standard_lead_time_days, :integer do
      default 1
      public? true
    end
    attribute :last_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :shipping_price, :decimal, public?: true
    attribute :currency_uom_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :supplier_product_name, :string, public?: true
    attribute :supplier_product_id, :string, public?: true
    attribute :can_drop_ship, :boolean do
      default false
      public? true
    end
    attribute :comments, :string, public?: true
    attribute :order_qty_increments, :decimal, public?: true
    attribute :product_tmpl_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :discount, :decimal do
      default 0
      public? true
    end
    attribute :sequence, :integer do
      default 1
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :supplier, UniboV4.Purchasing.Supplier do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:partner_id, :product_tmpl_id, :product_id, :last_price, :currency_uom_id, :minimum_order_quantity, :standard_lead_time_days, :discount, :available_from_date, :available_thru_date, :sequence, :supplier_product_name, :supplier_product_id, :can_drop_ship, :shipping_price, :comments, :order_qty_increments]
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
      validate present(:partner_id)
      validate present(:product_tmpl_id)
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
      accept [:last_price, :currency_uom_id, :minimum_order_quantity, :standard_lead_time_days, :discount, :available_from_date, :available_thru_date, :sequence, :supplier_product_name, :can_drop_ship, :shipping_price, :comments]
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
    validate compare(:last_price, greater_than_or_equal_to: 0)
    validate compare(:minimum_order_quantity, greater_than_or_equal_to: 0)
    validate compare(:standard_lead_time_days, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_supplier_product, [:partner_id, :product_tmpl_id, :minimum_order_quantity]
  end

  policies do
    policy action_type(:create) do
      authorize_if always()
    end
  end

end
