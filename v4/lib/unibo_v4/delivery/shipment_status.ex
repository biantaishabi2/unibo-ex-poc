# Workflow: shipment_status_record_flow — 状态历史记录
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Delivery.ShipmentStatus do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Delivery,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "delivery_shipment_statuses"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :status_id, :string do
      allow_nil? false
      public? true
    end
    attribute :status_date, :utc_datetime, public?: true
    attribute :change_by_user_login_id, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :shipment, UniboV4.Delivery.Shipment do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:status_id, :status_date, :change_by_user_login_id]
      validate present(:shipment_id)
      validate present(:status_id)
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
