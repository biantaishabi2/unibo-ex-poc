defmodule UniboExPoc.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # 动态合并编译器生成的域到 ash_domains 配置
    existing = Application.get_env(:travel, :ash_domains, [])
    generated = UniboExPoc.Generated.DomainRegistry.domains()
    Application.put_env(:travel, :ash_domains, Enum.uniq(existing ++ generated))

    children = [
      {DNSCluster, query: Application.get_env(:travel, :dns_cluster_query) || :ignore},
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
