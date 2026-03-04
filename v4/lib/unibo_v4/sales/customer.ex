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
defmodule UniboV4.Sales.Customer do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sales_customers"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :customer_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
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
    attribute :credit_limit, :decimal, public?: true
    attribute :payment_terms, :string, public?: true
    attribute :tax_id, :string, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :sales_orders, UniboV4.Sales.SalesOrder do
      public? true
    end
    has_many :quotes, UniboV4.Sales.Quote do
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
    update :update do
      primary? true
      accept [:name, :contact_name, :contact_phone, :contact_email, :billing_address, :shipping_address, :credit_limit, :payment_terms, :tax_id, :notes, :status]
      # skipped: validate present :name (incompatible with bulk update atomic path)
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
    update :block do
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
  end

  identities do
    identity :unique_customer_code, [:customer_code]
  end

end
