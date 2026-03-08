# Workflow: odometer_creation_flow — 里程记录创建
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Maintenance.Odometer do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "车辆里程记录，append-only 只追加不修改"
  end

  postgres do
    table "maintenance_odometers"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_odometer

    queries do
      get :get_maintenance_odometer, :read
      list :list_maintenance_odometers, :read
    end

    mutations do
      create :create_maintenance_odometer, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :value, :float do
      allow_nil? false
      public? true
      description "里程读数（group_operator=max，分组统计取最大值）"
    end
    attribute :date, :date do
      default &Date.utc_today/0
      public? true
      description "记录日期"
    end
    attribute :unit, :atom do
      constraints one_of: [:kilometers, :miles]
      public? true
      description "从 vehicle.odometer_unit 关联"
    end
    attribute :name, :string do
      public? true
      description "显示名，格式为 \"{vehicle} / {date}\""
    end
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :vehicle, UniboV4.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :driver, UniboV4.Maintenance.Party do
      public? true
      source_attribute :driver_party_id
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:value, :date]
      argument :vehicle_id, :uuid, allow_nil?: false
      change manage_relationship(:vehicle_id, :vehicle, type: :append, on_lookup: :relate)
      validate compare(:value, greater_than: 0)
      # message: "里程值不能为零或空"
      change set_attribute(:id, expr(id))
    end
  end

  validations do
  end

end
