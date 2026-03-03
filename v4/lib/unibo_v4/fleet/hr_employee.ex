defmodule UniboV4.Fleet.HrEmployee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Fleet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "fleet_hr_employees"
    repo UniboV4.Repo
  end

  graphql do
    type :fleet_hr_employee

    queries do
      get :get_fleet_hr_employee, :read
      list :list_fleet_hr_employees, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
