defmodule UniboV4.Blog.Website do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "blog_websites"
    repo UniboV4.Repo
  end

  graphql do
    type :blog_website

    queries do
      get :get_blog_website, :read
      list :list_blog_websites, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :homepage_url, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
