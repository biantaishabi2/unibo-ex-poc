defmodule HospitalSchedulingWeb.Router do
  use HospitalSchedulingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HospitalSchedulingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HospitalSchedulingWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/scheduling", SchedulingLive
    live "/scheduling/:page", SchedulingLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", HospitalSchedulingWeb do
  #   pipe_through :api
  # end
end
