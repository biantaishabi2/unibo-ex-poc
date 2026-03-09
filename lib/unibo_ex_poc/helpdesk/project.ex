defmodule UniboExPoc.Helpdesk.Project do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "项目占位实体（跨域引用，最小字段）"
  end

  postgres do
    table "helpdesk_projects"
    repo UniboExPoc.Repo
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
