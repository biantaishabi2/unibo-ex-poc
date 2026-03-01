defmodule UniboV4.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UniboV4.Repo,
      {DNSCluster, query: Application.get_env(:unibo_v4, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: UniboV4.PubSub},
      UniboV4Web.Telemetry,
      # 翻译 ETS 缓存（来自 unibo_i18n_runtime）
      Unibo.I18n.TranslationCache,
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
