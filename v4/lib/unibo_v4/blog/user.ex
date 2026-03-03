defmodule UniboV4.Blog.User do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "blog_users"
    repo UniboV4.Repo
  end

  graphql do
    type :blog_user

    queries do
      get :get_blog_user, :read
      list :list_blog_users, :read
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
