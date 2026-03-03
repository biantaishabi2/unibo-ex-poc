defmodule UniboV4Web.Router do
  use UniboV4Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UniboV4Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Unibo.I18n.LoadLocale
  end

  scope "/", UniboV4Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  # 子域 GraphQL 端点
  scope "/api" do
    pipe_through :api

    forward "/purchasing/graphql", UniboV4Web.Plugs.SubdomainGraphql.Purchasing
    forward "/sales/graphql", UniboV4Web.Plugs.SubdomainGraphql.Sales
    forward "/finance/graphql", UniboV4Web.Plugs.SubdomainGraphql.Finance
    forward "/production/graphql", UniboV4Web.Plugs.SubdomainGraphql.Production
    forward "/hr/graphql", UniboV4Web.Plugs.SubdomainGraphql.Hr
    forward "/project/graphql", UniboV4Web.Plugs.SubdomainGraphql.Project
    forward "/marketing/graphql", UniboV4Web.Plugs.SubdomainGraphql.Marketing
    forward "/knowledge/graphql", UniboV4Web.Plugs.SubdomainGraphql.Knowledge
    forward "/learning/graphql", UniboV4Web.Plugs.SubdomainGraphql.Learning
    forward "/engagement/graphql", UniboV4Web.Plugs.SubdomainGraphql.Engagement
    forward "/platform/graphql", UniboV4Web.Plugs.SubdomainGraphql.Platform
  end

  # 子域 GraphiQL Playground
  forward "/graphiql/purchasing", UniboV4Web.Plugs.SubdomainGraphiql.Purchasing
  forward "/graphiql/sales", UniboV4Web.Plugs.SubdomainGraphiql.Sales
  forward "/graphiql/finance", UniboV4Web.Plugs.SubdomainGraphiql.Finance
  forward "/graphiql/production", UniboV4Web.Plugs.SubdomainGraphiql.Production
  forward "/graphiql/hr", UniboV4Web.Plugs.SubdomainGraphiql.Hr
  forward "/graphiql/project", UniboV4Web.Plugs.SubdomainGraphiql.Project
  forward "/graphiql/marketing", UniboV4Web.Plugs.SubdomainGraphiql.Marketing
  forward "/graphiql/knowledge", UniboV4Web.Plugs.SubdomainGraphiql.Knowledge
  forward "/graphiql/learning", UniboV4Web.Plugs.SubdomainGraphiql.Learning
  forward "/graphiql/engagement", UniboV4Web.Plugs.SubdomainGraphiql.Engagement
  forward "/graphiql/platform", UniboV4Web.Plugs.SubdomainGraphiql.Platform
end
