defmodule UniboV4.Membership.ResUser do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Membership,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "membership_res_users"
    repo UniboV4.Repo
  end

  graphql do
    type :membership_res_user

    queries do
      get :get_membership_res_user, :read
      list :list_membership_res_users, :read
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
