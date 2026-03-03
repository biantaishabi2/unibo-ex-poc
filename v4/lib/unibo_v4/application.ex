defmodule UniboV4.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # 动态合并编译器生成的域到 ash_domains 配置
    existing = Application.get_env(:unibo_v4, :ash_domains, [])
    generated = UniboV4.Generated.DomainRegistry.domains()
    Application.put_env(:unibo_v4, :ash_domains, Enum.uniq(existing ++ generated))

    children = [
      UniboV4.Repo,
      {DNSCluster, query: Application.get_env(:unibo_v4, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UniboV4.PubSub},
      UniboV4Web.Telemetry,
      UniboV4Web.Endpoint
    ]

    opts = [strategy: :one_for_one, name: UniboV4.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    UniboV4Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
