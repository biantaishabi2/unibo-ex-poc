# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :unibo_ex_poc,
  ecto_repos: [UniboExPoc.Repo],
  ash_domains: [
    UniboExPoc.Purchasing,
    UniboExPoc.PurchasingV2,
    UniboExPoc.PurchasingV3,
    UniboExPoc.Travel.Travel
  ],
  travel_host_bridge: UniboExPoc.TravelHost.DefaultBridge,
  generators: [timestamp_type: :utc_datetime]

config :unibo_ex_poc, :travel_host_shop_bridge,
  bridge_client: UniboExPoc.TravelHost.ShopBridgeClient,
  transport: UniboExPoc.TravelHost.HTTPTransport,
  base_url: nil,
  endpoint_paths: %{
    resolve_context: "/internal/api/travel_host_bridge/resolve_context",
    quote: "/internal/api/travel_host_bridge/quote",
    execute_payment: "/internal/api/travel_host_bridge/execute_payment"
  },
  headers: [],
  http_options: []

config :unibo_ex_poc, UniboExPocWeb.Graphql.RuntimeConfig,
  source: :default,
  schema: UniboExPocWeb.Schema,
  manifest: "priv/unibo/graphql/manifest.json"

# Configures the endpoint
config :unibo_ex_poc, UniboExPocWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: UniboExPocWeb.ErrorHTML, json: UniboExPocWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: UniboExPoc.PubSub,
  live_view: [signing_salt: "MSGr57i3"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  unibo_ex_poc: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  unibo_ex_poc: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
