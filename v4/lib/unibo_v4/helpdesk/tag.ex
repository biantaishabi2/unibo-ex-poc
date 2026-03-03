defmodule UniboV4.Helpdesk.Tag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "helpdesk_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :helpdesk_tag

    queries do
      get :get_helpdesk_tag, :read
      list :list_helpdesk_tags, :read
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
