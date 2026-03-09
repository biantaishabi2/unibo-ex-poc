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
    UniboExPoc.Accounting,
    UniboExPoc.Analytic,
    UniboExPoc.Approvals,
    UniboExPoc.Barcode,
    UniboExPoc.Blog,
    UniboExPoc.CRM,
    UniboExPoc.Calendar,
    UniboExPoc.Communication,
    UniboExPoc.Currency,
    UniboExPoc.DataRecycle,
    UniboExPoc.Delivery,
    UniboExPoc.Documents,
    UniboExPoc.ELearning,
    UniboExPoc.Ecommerce,
    UniboExPoc.Events,
    UniboExPoc.Expenses,
    UniboExPoc.Fleet,
    UniboExPoc.Forum,
    UniboExPoc.Gamification,
    UniboExPoc.HR,
    UniboExPoc.Helpdesk,
    UniboExPoc.Inventory,
    UniboExPoc.IoT,
    UniboExPoc.Knowledge,
    UniboExPoc.LiveChat,
    UniboExPoc.Loyalty,
    UniboExPoc.Lunch,
    UniboExPoc.Maintenance,
    UniboExPoc.Manufacturing,
    UniboExPoc.Marketing,
    UniboExPoc.Membership,
    UniboExPoc.Ofbiz.Accounting,
    UniboExPoc.Ofbiz.Common,
    UniboExPoc.Ofbiz.Content,
    UniboExPoc.Ofbiz.HumanRes,
    UniboExPoc.Ofbiz.Manufacturing,
    UniboExPoc.Ofbiz.Marketing,
    UniboExPoc.Ofbiz.Order,
    UniboExPoc.Ofbiz.Party,
    UniboExPoc.Ofbiz.Product,
    UniboExPoc.Ofbiz.Security,
    UniboExPoc.Ofbiz.Service,
    UniboExPoc.Ofbiz.Shipment,
    UniboExPoc.Ofbiz.WorkEffort,
    UniboExPoc.Organization,
    UniboExPoc.PLM,
    UniboExPoc.POS,
    UniboExPoc.Payment,
    UniboExPoc.Project,
    UniboExPoc.Purchasing,
    UniboExPoc.Quality,
    UniboExPoc.Rating,
    UniboExPoc.Rental,
    UniboExPoc.Repair,
    UniboExPoc.Sales,
    UniboExPoc.Sign,
    UniboExPoc.Spreadsheet,
    UniboExPoc.Studio,
    UniboExPoc.Subscriptions,
    UniboExPoc.Survey,
    UniboExPoc.Travel,
    UniboExPoc.Uom,
    UniboExPoc.Website
  ],
  generators: [timestamp_type: :utc_datetime]

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
