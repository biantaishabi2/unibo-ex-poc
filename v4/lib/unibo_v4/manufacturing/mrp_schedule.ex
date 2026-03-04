# Workflow: mrp_schedule_create_flow — MRP 排程创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Manufacturing.MrpSchedule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "manufacturing_mrp_schedules"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_code, :string do
      allow_nil? false
      public? true
    end
    attribute :event_type, :atom do
      allow_nil? false
      constraints one_of: [:demand, :supply, :forecast]
      public? true
    end
    attribute :quantity, :decimal do
      allow_nil? false
      public? true
    end
    attribute :event_date, :date do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_code, :event_type, :quantity, :event_date, :description]
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
  end

  validations do
    validate compare(:quantity, greater_than: 0)
  end

end
