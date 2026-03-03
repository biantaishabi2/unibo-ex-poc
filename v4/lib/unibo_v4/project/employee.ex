defmodule UniboV4.Project.Employee do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "project_employees"
    repo UniboV4.Repo
  end

  graphql do
    type :project_employee

    queries do
      get :get_project_employee, :read
      list :list_project_employees, :read
    end

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
    defaults [:read, :update]
  end

end
