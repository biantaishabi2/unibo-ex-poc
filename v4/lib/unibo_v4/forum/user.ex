defmodule UniboV4.Forum.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "forum_users"
    repo UniboV4.Repo
  end

  graphql do
    type :forum_user

    queries do
      get :get_forum_user, :read
      list :list_forum_users, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :karma, :integer do
      default 0
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
