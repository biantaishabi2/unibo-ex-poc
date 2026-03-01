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
    plug UniboV4Web.Plugs.LoadLocale
  end

  scope "/", UniboV4Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api" do
    pipe_through :api

    forward "/graphql",
      Absinthe.Plug,
      schema: UniboV4Web.Schema

    forward "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: UniboV4Web.Schema,
      interface: :playground
  end
end
