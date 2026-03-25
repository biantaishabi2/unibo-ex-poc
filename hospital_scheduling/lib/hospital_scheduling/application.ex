defmodule HospitalScheduling.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:hospital_scheduling, :dns_cluster_query) || :ignore},
      HospitalScheduling.Repo,
      {Phoenix.PubSub, name: HospitalScheduling.InternalPubSub},
      HospitalSchedulingWeb.Telemetry,
      HospitalSchedulingWeb.Endpoint,
      HospitalScheduling.AsyncRuntime.Store,
      HospitalScheduling.AsyncRuntime.Queue,
      HospitalScheduling.AsyncRuntime.Telemetry
    ]

    opts = [strategy: :one_for_one, name: HospitalScheduling.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    HospitalSchedulingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
