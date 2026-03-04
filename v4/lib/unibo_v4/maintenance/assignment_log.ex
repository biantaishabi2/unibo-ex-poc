# Workflow: assignment_log_creation_flow — 驾驶员分配记录创建
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Maintenance.AssignmentLog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "maintenance_assignment_logs"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :date_start, :date, public?: true
    attribute :date_end, :date, public?: true
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :vehicle, UniboV4.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboV4.Maintenance.Partner do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date_start, :date_end]
      argument :vehicle_id, :uuid, allow_nil?: false
      argument :driver_id, :uuid, allow_nil?: false
      change manage_relationship(:vehicle_id, :vehicle, type: :append, on_lookup: :relate)
      change manage_relationship(:driver_id, :driver, type: :append, on_lookup: :relate)
      validate present(:date_start)
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

end
