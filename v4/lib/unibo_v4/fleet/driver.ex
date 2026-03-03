# Workflow: driver_lifecycle — 驾驶员生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> deactivate
#   deactivate --> [*]
# ```
defmodule UniboV4.Fleet.Fleet.Driver do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Fleet.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "fleet_drivers"
    repo UniboV4.Repo
  end

  graphql do
    type :fleet_driver

    queries do
      get :get_fleet_driver, :read
      list :list_fleet_drivers, :read
    end

    mutations do
      create :create_fleet_driver, :create
      update :update_fleet_driver, :update
      update :deactivate_fleet_driver, :deactivate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :license_number, :string do
      allow_nil? false
      public? true
    end
    attribute :license_type, :atom do
      constraints one_of: [:A1, :A2, :A3, :B1, :B2, :C1, :C2, :C3, :D, :E]
      public? true
    end
    attribute :license_expiry_date, :date, public?: true
    attribute :phone, :string, public?: true
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_license_expired
  end

  relationships do
    belongs_to :employee, UniboV4.Fleet.Fleet.HrEmployee do
      public? true
    end
    has_many :assignments, UniboV4.Fleet.Fleet.VehicleAssignment do
      public? true
      destination_attribute :driver_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :license_number, :license_type, :license_expiry_date, :phone]
      argument :hr_employee_id, :string
      validate present(:name)
      validate present(:license_number)
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
      accept [:name, :license_number, :license_type, :license_expiry_date, :phone, :status]
      argument :hr_employee_id, :string
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
    update :deactivate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有在职驾驶员可以停用"
      change set_attribute(:status, :inactive)
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
    identity :unique_license_number, [:license_number]
  end

end
