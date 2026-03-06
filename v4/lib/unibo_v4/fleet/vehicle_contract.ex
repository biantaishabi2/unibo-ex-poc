# Workflow: vehicle_contract_flow — 车辆合同流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> activate
#   create --> terminate
#   activate --> renew
#   activate --> terminate
#   renew --> renew
#   renew --> terminate
#   terminate --> [*]
# ```
defmodule UniboV4.Fleet.VehicleContract do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Fleet.VehicleContract.Notifier]

  postgres do
    table "fleet_vehicle_contracts"
    repo UniboV4.Repo
  end

  graphql do
    type :fleet_vehicle_contract

    queries do
      get :get_fleet_vehicle_contract, :read
      list :list_fleet_vehicle_contracts, :read
    end

    mutations do
      create :create_fleet_vehicle_contract, :create
      update :activate_fleet_vehicle_contract, :activate
      update :renew_fleet_vehicle_contract, :renew
      update :terminate_fleet_vehicle_contract, :terminate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :contract_type, :atom do
      allow_nil? false
      constraints one_of: [:lease, :insurance, :maintenance_plan, :other]
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :expired, :terminated]
      default :draft
      public? true
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date, public?: true
    attribute :vendor, :string, public?: true
    attribute :contract_number, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :recurring_cost, :decimal, public?: true
    attribute :recurring_period, :atom do
      constraints one_of: [:monthly, :quarterly, :yearly]
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_expired
    # TODO: 不支持的 calculation 表达式 :total_cost
  end

  relationships do
    belongs_to :fleet_vehicle, UniboV4.Fleet.FleetVehicle do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:contract_type, :start_date, :end_date, :vendor, :contract_number, :amount, :recurring_cost, :recurring_period, :notes]
      argument :fleet_vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:fleet_vehicle_id, :fleet_vehicle, type: :append, on_lookup: :relate)
      validate present(:fleet_vehicle_id)
      validate present(:contract_type)
      validate present(:start_date)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :activate do
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态的合同可以激活"
      change set_attribute(:status, :active)
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
    update :renew do
      accept [:end_date, :amount, :recurring_cost, :notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:active, :expired] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:active, :expired]}))
        end
      end
      # message: "只有生效中或已过期的合同可以续签"
      change set_attribute(:status, :active)
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
    update :terminate do
      accept [:notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :active] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :active]}))
        end
      end
      # message: "只有草稿或生效中的合同可以终止"
      change set_attribute(:status, :terminated)
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

end
