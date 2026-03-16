defmodule UniboExPocWeb.Router do
  use UniboExPocWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UniboExPocWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UniboExPocWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/travel", TravelLive
    live "/travel/:page", TravelLive
  end

  # GraphQL — 验证无 BFF 架构
  scope "/api" do
    pipe_through :api

    post "/graphql", UniboExPocWeb.GraphqlController, :execute

    # 开发环境 GraphiQL 界面
    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: UniboExPocWeb.Schema,
      interface: :playground
  end
end
