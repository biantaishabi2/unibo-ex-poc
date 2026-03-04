# Workflow: odometer_creation_flow — 里程记录创建
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Maintenance.Odometer do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_odometers"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :value, :float do
      allow_nil? false
      public? true
    end
    attribute :date, :date do
      default &Date.utc_today/0
      public? true
    end
    attribute :unit, :atom do
      constraints one_of: [:kilometers, :miles]
      public? true
    end
    attribute :name, :string, public?: true
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :vehicle, UniboV4.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboV4.Maintenance.Partner do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:value, :date]
      argument :vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:vehicle_id, :vehicle, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 positive
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  validations do
    # TODO: 不支持的校验规则 append_only
  end

end
