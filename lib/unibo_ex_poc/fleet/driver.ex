# Workflow: driver_lifecycle — 驾驶员生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> deactivate
#   update --> deactivate
#   deactivate --> [*]
# ```
defmodule UniboV4.Fleet.Driver do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "驾驶员，通过 employee_id 关联 HR 域 Employee（跨域引用）"
  end

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
      description "驾驶员姓名"
    end
    attribute :license_number, :string do
      allow_nil? false
      public? true
      description "驾驶证号"
    end
    attribute :license_type, :atom do
      constraints one_of: [:A1, :A2, :A3, :B1, :B2, :C1, :C2, :C3, :D, :E]
      public? true
      description "驾照类型"
    end
    attribute :license_expiry_date, :date do
      public? true
      description "驾驶证有效期"
    end
    attribute :phone, :string do
      public? true
      description "联系电话"
    end
    attribute :status, :atom do
      constraints one_of: [:active, :inactive]
      default :active
      public? true
      description "驾驶员状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :is_license_expired, :boolean, expr(is_past(license_expiry_date))
  end

  relationships do
    belongs_to :party, UniboV4.Fleet.Party do
      public? true
    end
    belongs_to :employee, UniboV4.Fleet.HrEmployee do
      public? true
    end
    has_many :assignments, UniboV4.Fleet.VehicleAssignment do
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :license_number, :license_type, :license_expiry_date, :phone, :status]
      argument :hr_employee_id, :string
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      description "停用驾驶员"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_license_number, [:license_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
