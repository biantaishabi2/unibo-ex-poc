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

  # 子域 GraphQL 端点（暂时禁用 — 等编译器修复 graphql 暴露后重新启用）
  # scope "/api" do
  #   pipe_through :api
  #   forward "/purchasing/graphql", UniboV4Web.Plugs.SubdomainGraphql.Purchasing
  #   forward "/sales/graphql", UniboV4Web.Plugs.SubdomainGraphql.Sales
  # end
end
