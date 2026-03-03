# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :unibo_v4,
  ecto_repos: [UniboV4.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [
    # 本地认证域（不由编译器生成）
    UniboV4.Accounts,
    # 以下由 UniBO 编译器自动生成（compile-project --emit-domain-registry）
    UniboV4.Accounting,
    UniboV4.Analytic,
    UniboV4.Approvals,
    UniboV4.Barcode,
    UniboV4.Blog,
    UniboV4.CRM,
    UniboV4.Calendar,
    UniboV4.Communication,
    UniboV4.Currency,
    UniboV4.DataRecycle,
    UniboV4.Delivery,
    UniboV4.Documents,
    UniboV4.ELearning,
    UniboV4.Ecommerce,
    UniboV4.Events,
    UniboV4.Expenses,
    UniboV4.Fleet,
    UniboV4.Forum,
    UniboV4.Gamification,
    UniboV4.HR,
    UniboV4.Helpdesk,
    UniboV4.Inventory,
    UniboV4.IoT,
    UniboV4.Knowledge,
    UniboV4.LiveChat,
    UniboV4.Loyalty,
    UniboV4.Lunch,
    UniboV4.Maintenance,
    UniboV4.Manufacturing,
    UniboV4.Marketing,
    UniboV4.Membership,
    UniboV4.PLM,
    UniboV4.POS,
    UniboV4.Payment,
    UniboV4.Project,
    UniboV4.Purchasing,
    UniboV4.Quality,
    UniboV4.Rating,
    UniboV4.Rental,
    UniboV4.Repair,
    UniboV4.Sales,
    UniboV4.Sign,
    UniboV4.Spreadsheet,
    UniboV4.Studio,
    UniboV4.Subscriptions,
    UniboV4.Survey,
    UniboV4.Uom
  ]

# Configures the endpoint
config :unibo_v4, UniboV4Web.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: UniboV4Web.ErrorHTML, json: UniboV4Web.ErrorJSON],
    layout: false
  ],
  pubsub_server: UniboV4.PubSub,
  live_view: [signing_salt: "5aC/HEAe"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  unibo_v4: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  unibo_v4: [
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
