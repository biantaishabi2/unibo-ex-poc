defmodule UniboV4.Helpdesk.Project do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_projects"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_project

    queries do
      get :get_helpdesk_project, :read
      list :list_helpdesk_projects, :read
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
