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
defmodule UniboExPoc.Fleet.VehicleContract do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Fleet.VehicleContract.Notifier]

  resource do
    description "车辆合同（租赁、保险等）"
  end

  postgres do
    table "fleet_vehicle_contracts"
    repo UniboExPoc.Repo
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
      description "合同类型"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :expired, :terminated]
      default :draft
      public? true
      description "合同状态"
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
      description "合同开始日期"
    end
    attribute :end_date, :date do
      public? true
      description "合同结束日期"
    end
    attribute :vendor, :string do
      public? true
      description "合同供应商/保险公司"
    end
    attribute :contract_number, :string do
      public? true
      description "合同编号"
    end
    attribute :amount, :decimal do
      public? true
      description "合同金额"
    end
    attribute :recurring_cost, :decimal do
      public? true
      description "周期费用（月租/年费等）"
    end
    attribute :recurring_period, :atom do
      constraints one_of: [:monthly, :quarterly, :yearly]
      public? true
      description "周期类型"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :is_expired, :boolean, expr(is_past(end_date))
    calculate :total_cost, :decimal, expr(compute_contract_total_cost(amount, recurring_cost, recurring_period, start_date, end_date))
  end

  relationships do
    belongs_to :fleet_vehicle, UniboExPoc.Fleet.FleetVehicle do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:fleet_vehicle_id, :contract_type, :start_date, :end_date, :vendor, :contract_number, :amount, :recurring_cost, :recurring_period, :notes]
      argument :fleet_vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:fleet_vehicle_id, :fleet_vehicle, type: :append, on_lookup: :relate)
      validate present(:fleet_vehicle_id)
      validate present(:contract_type)
      validate present(:start_date)
      change set_attribute(:id, expr(id))
    end
    update :activate do
      description "激活合同（draft -> active）"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :renew do
      description "续签合同（active/expired -> active，更新结束日期和金额）"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :terminate do
      description "终止合同"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
