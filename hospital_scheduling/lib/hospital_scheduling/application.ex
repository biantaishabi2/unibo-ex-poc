defmodule HospitalScheduling.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # 动态合并编译器生成的域到 ash_domains 配置
    existing = Application.get_env(:hospital_scheduling, :ash_domains, [])
    generated = HospitalScheduling.Generated.DomainRegistry.domains()
    Application.put_env(:hospital_scheduling, :ash_domains, Enum.uniq(existing ++ generated))

    children = [
      {DNSCluster, query: Application.get_env(:hospital_scheduling, :dns_cluster_query) || :ignore},
      HospitalScheduling.Repo,
      {Phoenix.PubSub, name: HospitalScheduling.PubSub},
      HospitalSchedulingWeb.Telemetry,
      HospitalSchedulingWeb.Endpoint
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
