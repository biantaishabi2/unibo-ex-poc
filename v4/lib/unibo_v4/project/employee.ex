defmodule UniboV4.Project.Employee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "project_employees"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :hourly_cost, :decimal, public?: true
  end

  relationships do
    belongs_to :user, UniboV4.Project.User do
      public? true
    end
  end

  actions do
    defaults [:read]
  end

end
