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
defmodule UniboV4.Purchasing.SupplierProduct do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Purchasing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "purchasing_supplier_products"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string, public?: true
    attribute :unit_price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :min_order_quantity, :integer do
      default 1
      public? true
    end
    attribute :lead_time_days, :integer, public?: true
    attribute :available_from, :date, public?: true
    attribute :available_thru, :date, public?: true
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
      accept [:product_name, :product_code, :unit_price, :currency, :min_order_quantity, :lead_time_days, :available_from, :available_thru]
      argument :supplier_id, :uuid, allow_nil?: false
      change manage_relationship(:supplier_id, :supplier, type: :append, on_lookup: :relate)
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
      accept [:unit_price, :currency, :min_order_quantity, :lead_time_days, :available_from, :available_thru]
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
    validate compare(:unit_price, greater_than_or_equal_to: 0)
    validate compare(:min_order_quantity, greater_than: 0)
  end

end
