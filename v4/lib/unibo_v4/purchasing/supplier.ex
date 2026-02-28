defmodule UniboV4.Purchasing.Supplier do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "suppliers"
    repo UniboV4.Repo
  end

  graphql do
    type :supplier

    queries do
      get :get_supplier, :read
      list :list_suppliers, :read
    end

    mutations do
      create :create_supplier, :create
      update :update_supplier, :update
      update :activate_supplier, :activate
      update :block_supplier, :block
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :supplier_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:active, :inactive, :blocked]
      default :active
    end
    attribute :contact_name, :string
    attribute :contact_phone, :string
    attribute :contact_email, :string
    attribute :address, :string
    attribute :payment_terms, :string
    attribute :tax_id, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :products, UniboV4.Purchasing.SupplierProduct
    has_many :purchase_orders, UniboV4.Purchasing.PurchaseOrder
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:supplier_code, :name, :contact_name, :contact_phone, :contact_email, :address, :payment_terms, :tax_id, :notes]
      validate present(:supplier_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :contact_name, :contact_phone, :contact_email, :address, :payment_terms, :tax_id, :notes, :status]
    end
    update :activate do
      accept []
      validate attribute_in(:status, [:inactive, :blocked]) do
        message "只有非活跃或冻结状态可以启用"
      end
      change set_attribute(:status, :active)
    end
    update :block do
      accept []
      validate attribute_equals(:status, :active) do
        message "只有活跃状态可以冻结"
      end
      change set_attribute(:status, :blocked)
    end
  end

  identities do
    identity :unique_supplier_code, [:supplier_code]
  end

end
