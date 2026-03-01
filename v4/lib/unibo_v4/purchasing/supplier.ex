# Workflow: supplier_lifecycle — 供应商管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> block
#   update --> update
#   update --> activate
#   update --> block
#   activate --> update
#   activate --> block
#   block --> [*]
# ```
defmodule UniboV4.Purchasing.Supplier do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "purchasing_suppliers"
    repo UniboV4.Repo
  end

  graphql do
    type :purchasing_supplier

    queries do
      get :get_purchasing_supplier, :read
      list :list_purchasing_suppliers, :read
      get :get_list_purchasing_supplier, :list
      list :list_list_purchasing_suppliers, :list
      get :get_search_purchasing_supplier, :search
      list :list_search_purchasing_suppliers, :search
      get :get_get_purchasing_supplier, :get
      list :list_get_purchasing_suppliers, :get
      get :get_preview_purchasing_supplier, :preview
      list :list_preview_purchasing_suppliers, :preview
      get :get_compute_purchasing_supplier, :compute
      list :list_compute_purchasing_suppliers, :compute
      get :get_lookup_purchasing_supplier, :lookup
      list :list_lookup_purchasing_suppliers, :lookup
    end

    mutations do
      create :create_purchasing_supplier, :create
      update :update_purchasing_supplier, :update
      update :activate_purchasing_supplier, :activate
      update :block_purchasing_supplier, :block
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :supplier_code, :string do
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
    attribute :contact_name, :string, public?: true
    attribute :contact_phone, :string, public?: true
    attribute :contact_email, :string, public?: true
    attribute :address, :string, public?: true
    attribute :payment_terms, :string, public?: true
    attribute :tax_id, :string, public?: true
    attribute :purchase_warn, :atom do
      constraints one_of: [:no_message, :warning, :block]
      default :no_message
      public? true
    end
    attribute :purchase_warn_msg, :string, public?: true
    attribute :parent_id, :uuid, public?: true
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :products, UniboV4.Purchasing.SupplierProduct do
      public? true
    end
    has_many :purchase_orders, UniboV4.Purchasing.PurchaseOrder do
      public? true
    end
    has_many :supplier_infos, UniboV4.Purchasing.ProductSupplierinfo do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:supplier_code, :name, :contact_name, :contact_phone, :contact_email, :address, :payment_terms, :tax_id, :purchase_warn, :purchase_warn_msg, :parent_id, :notes]
      validate present(:supplier_code)
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
      accept [:name, :contact_name, :contact_phone, :contact_email, :address, :payment_terms, :tax_id, :purchase_warn, :purchase_warn_msg, :notes, :status]
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
    update :activate do
      accept []
      # skipped: validate present :name (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:inactive, :blocked] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:inactive, :blocked]}))
        end
      end
      # message: "只有非活跃或冻结状态可以启用"
      change set_attribute(:status, :active)
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
    identity :unique_supplier_code, [:supplier_code]
  end

end
