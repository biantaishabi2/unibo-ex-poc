# Workflow: assignment_management — 技术员分配管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Helpdesk.FieldServiceAssignment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "helpdesk_field_service_assignments"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      default "technician"
      public? true
    end
    attribute :from_date, :date do
      allow_nil? false
      public? true
    end
    attribute :thru_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :service_order, UniboV4.Helpdesk.FieldServiceOrder do
      public? true
      allow_nil? false
    end
    belongs_to :technician, UniboV4.Helpdesk.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:role, :from_date, :thru_date]
      argument :service_order_id, :uuid, allow_nil?: false
      argument :technician_id, :uuid, allow_nil?: false
      change manage_relationship(:service_order_id, :service_order, type: :append, on_lookup: :relate)
      change manage_relationship(:technician_id, :technician, type: :append, on_lookup: :relate)
      validate present(:from_date)
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
