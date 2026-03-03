defmodule UniboV4.DataRecycle.ResUser do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.DataRecycle,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "data_recycle_res_users"
    repo UniboV4.Repo
  end

  graphql do
    type :data_recycle_res_user

    queries do
      get :get_data_recycle_res_user, :read
      list :list_data_recycle_res_users, :read
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
