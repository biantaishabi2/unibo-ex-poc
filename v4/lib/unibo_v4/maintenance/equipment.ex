# Workflow: equipment_lifecycle — 设备生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> retire
#   update --> retire
#   retire --> [*]
# ```
defmodule UniboV4.Maintenance.Equipment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_equipments"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :asset_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :serial_number, :string, public?: true
    attribute :status, :atom do
      constraints one_of: [:operational, :maintenance, :retired]
      default :operational
      public? true
    end
    attribute :category, :string, public?: true
    attribute :location, :string, public?: true
    attribute :purchase_date, :date, public?: true
    attribute :warranty_expiry_date, :date, public?: true
    attribute :effective_date, :date, public?: true
    attribute :notes, :string, public?: true
    attribute :maintenance_count, :integer, public?: true
    attribute :maintenance_open_count, :integer, public?: true
    attribute :mttr, :decimal, public?: true
    attribute :mtbf, :decimal, public?: true
    attribute :estimated_next_failure, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :maintenance_requests, UniboV4.Maintenance.MaintenanceRequest do
      public? true
    end
    belongs_to :category_ref, UniboV4.Maintenance.EquipmentCategory do
      public? true
    end
    belongs_to :owner, UniboV4.Maintenance.User do
      public? true
    end
    belongs_to :technician, UniboV4.Maintenance.User do
      public? true
    end
    belongs_to :company, UniboV4.Maintenance.Company do
      public? true
      allow_nil? false
    end
    belongs_to :maintenance_team, UniboV4.Maintenance.MaintenanceTeam do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:asset_code, :name, :category, :location, :purchase_date, :warranty_expiry_date, :serial_number, :effective_date, :notes]
      argument :company_id, :uuid, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:asset_code)
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
    update :update do
      primary? true
      accept [:name, :status, :category, :location, :effective_date, :notes]
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
    update :retire do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:operational, :maintenance] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:operational, :maintenance]}))
        end
      end
      # message: "只有运行中或维护中状态可以报废"
      change set_attribute(:status, :retired)
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

  validations do
    # TODO: 不支持的校验规则 unique
    # TODO: 不支持的校验规则 company_isolation
  end

  identities do
    identity :unique_asset_code, [:asset_code]
    identity :unique_serial_number, [:serial_number]
  end

end
