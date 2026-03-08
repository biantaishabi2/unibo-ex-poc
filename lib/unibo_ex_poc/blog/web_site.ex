defmodule UniboV4.Blog.WebSite do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域站点占位实体（完整定义在 website 域）"
  end

  postgres do
    table "blog_web_sites"
    repo UniboV4.Repo
  end

  graphql do
    type :blog_web_site

    queries do
      get :get_blog_web_site, :read
      list :list_blog_web_sites, :read
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
