defmodule Travel.MixProject do
  use Mix.Project

  def project do
    [
      app: :travel,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {UniboExPoc.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:ash, "~> 3.18"},
      {:simple_sat, "~> 0.1"},
      {:ash_postgres, "~> 2.6"},
      {:ash_phoenix, "~> 2.3"},
      {:ash_graphql, "~> 1.8"},
      {:absinthe_plug, "~> 1.5"},
      {:unibo_graphql_runtime,
       github: "biantaishabi2/unibo",
       ref: "c7e4696750d0e6d5936918f8bfeb073bc1b372f4",
       sparse: "targets/elixir/unibo_graphql_runtime"},
      {:ash_paper_trail, "~> 0.5"},
      {:ash_archival, "~> 2.0"},
      {:unibo_bdd_runtime, github: "biantaishabi2/unibo", branch: "master", sparse: "targets/elixir/unibo_bdd_runtime"},
      {:stitch_ui, path: "../../stitch/packages/liveview"},
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
