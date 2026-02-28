defmodule UniboV4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UniboV4Web.Telemetry,
      UniboV4.Repo,
      {DNSCluster, query: Application.get_env(:unibo_v4, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UniboV4.PubSub},
      # Start a worker by calling: UniboV4.Worker.start_link(arg)
      # {UniboV4.Worker, arg},
      # Start to serve requests, typically the last entry
      UniboV4Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UniboV4.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UniboV4Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
