# Workflow: lot_write_flow — 批次/序列号写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Inventory.Lot do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "inventory_lots"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :lot_number, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
    end
    attribute :expiration_date, :utc_datetime, public?: true
    attribute :use_date, :utc_datetime, public?: true
    attribute :removal_date, :utc_datetime, public?: true
    attribute :alert_date, :utc_datetime, public?: true
    attribute :manufacturing_date, :date, public?: true
    attribute :product_expiry_alert, :boolean do
      default false
      public? true
    end
    attribute :product_expiry_reminded, :boolean do
      default false
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:lot_number, :product_code, :expiration_date, :use_date, :removal_date, :alert_date, :manufacturing_date, :product_expiry_reminded, :notes]
      validate present(:lot_number)
      validate present(:product_code)
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
      accept [:expiration_date, :use_date, :removal_date, :alert_date, :product_expiry_reminded, :notes]
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
    identity :unique_lot_number, [:lot_number]
  end

end
