defmodule UniboV4.HR.Attendance do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "attendances"
    repo UniboV4.Repo
  end

  graphql do
    type :attendance

    queries do
      get :get_attendance, :read
      list :list_attendances, :read
    end

    mutations do
      create :create_attendance, :create
      update :check_out_attendance, :check_out
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :check_in, :utc_datetime, allow_nil?: false, public?: true
    attribute :check_out, :utc_datetime, public?: true
    attribute :worked_hours, :decimal, public?: true
    attribute :attendance_date, :date, allow_nil?: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:check_in, :attendance_date]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
    end
    update :check_out do
      accept [:check_out, :worked_hours]
    end
  end

end
