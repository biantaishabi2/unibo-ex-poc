defmodule UniboV4.Maintenance.MaintenanceSchedule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_schedules"
    repo UniboV4.Repo
  end

  graphql do
    type :maintenance_schedule

    queries do
      get :get_maintenance_schedule, :read
      list :list_maintenance_schedules, :read
    end

    mutations do
      create :create_maintenance_schedule, :create
      update :update_maintenance_schedule, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :schedule_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :frequency, :atom do
      allow_nil? false
      constraints one_of: [:daily, :weekly, :monthly, :quarterly, :yearly]
        public? true
    end
    attribute :next_due_date, :date, allow_nil?: false, public?: true
    attribute :is_active, :boolean, default: true, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboV4.Maintenance.Equipment do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:schedule_code, :name, :frequency, :next_due_date, :description]
      argument :equipment_id, :uuid, allow_nil?: false
      change manage_relationship(:equipment_id, :equipment, type: :append, on_lookup: :relate)
      validate present(:schedule_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :frequency, :next_due_date, :is_active, :description]
    end
  end

  identities do
    identity :unique_schedule_code, [:schedule_code]
  end

end
