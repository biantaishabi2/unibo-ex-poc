defmodule UniboV4.IoT.Org do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "io_t_orgs"
    repo UniboV4.Repo
  end

  graphql do
    type :io_t_org

    queries do
      get :get_io_t_org, :read
      list :list_io_t_orgs, :read
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
