defmodule UniboV4.Project.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "project_users"
    repo UniboV4.Repo
  end

  graphql do
    type :project_user

    queries do
      get :get_project_user, :read
      list :list_project_users, :read
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
