defmodule UniboExPoc.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:unibo_ex_poc, :dns_cluster_query) || :ignore},
      UniboExPoc.Repo,
      {Phoenix.PubSub, name: UniboExPoc.PubSub},
      UniboExPocWeb.Telemetry,
      UniboExPocWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: UniboExPoc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    UniboExPocWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
