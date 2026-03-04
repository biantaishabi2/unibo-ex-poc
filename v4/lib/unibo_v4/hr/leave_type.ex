# Workflow: leave_type_write_flow — LeaveType 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.HR.LeaveType do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "hr_leave_types"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :code, :string do
      allow_nil? false
      public? true
    end
    attribute :max_days_per_year, :decimal, public?: true
    attribute :is_paid, :boolean do
      default true
      public? true
    end
    attribute :requires_allocation, :atom do
      constraints one_of: [:yes, :no]
      default :no
      public? true
    end
    attribute :leave_validation_type, :atom do
      constraints one_of: [:no_validation, :manager, :hr, :both]
      default :manager
      public? true
    end
    attribute :allows_negative, :boolean do
      default false
      public? true
    end
    attribute :max_allowed_negative, :decimal, public?: true
    attribute :request_unit, :atom do
      constraints one_of: [:day, :half_day, :hour]
      default :day
      public? true
    end
    attribute :create_calendar_meeting, :boolean do
      default false
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :leave_requests, UniboV4.HR.LeaveRequest do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :code, :max_days_per_year, :is_paid, :requires_allocation, :leave_validation_type, :allows_negative, :max_allowed_negative, :request_unit, :create_calendar_meeting, :description]
      validate present(:name)
      validate present(:code)
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
      accept [:name, :max_days_per_year, :is_paid, :requires_allocation, :leave_validation_type, :allows_negative, :max_allowed_negative, :request_unit, :create_calendar_meeting, :description]
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
    identity :unique_leave_type_code, [:code]
  end

end
