defmodule UniboV4.Sales.Customer do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "customers"
    repo UniboV4.Repo
  end

  graphql do
    type :customer

    queries do
      get :get_customer, :read
      list :list_customers, :read
    end

    mutations do
      create :create_customer, :create
      update :update_customer, :update
      update :block_customer, :block
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :customer_code, :string, allow_nil?: false
    attribute :name, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:active, :inactive, :blocked]
      default :active
    end
    attribute :customer_type, :atom do
      constraints one_of: [:individual, :company]
      default :company
    end
    attribute :contact_name, :string
    attribute :contact_phone, :string
    attribute :contact_email, :string
    attribute :billing_address, :string
    attribute :shipping_address, :string
    attribute :credit_limit, :decimal
    attribute :payment_terms, :string
    attribute :tax_id, :string
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :sales_orders, UniboV4.Sales.SalesOrder
    has_many :quotes, UniboV4.Sales.Quote
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:customer_code, :name, :customer_type, :contact_name, :contact_phone, :contact_email, :billing_address, :shipping_address, :credit_limit, :payment_terms, :tax_id, :notes]
      validate present(:customer_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :contact_name, :contact_phone, :contact_email, :billing_address, :shipping_address, :credit_limit, :payment_terms, :tax_id, :notes, :status]
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
    identity :unique_customer_code, [:customer_code]
  end

end
