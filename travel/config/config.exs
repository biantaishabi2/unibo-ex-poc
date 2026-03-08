import Config

config :travel,
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
  travel_host_bridge: UniboExPoc.TravelHost.DefaultBridge,
  generators: [timestamp_type: :utc_datetime]

config :travel, :travel_host_shop_bridge,
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

config :travel, UniboExPocWeb.Graphql.RuntimeConfig,
  source: :default,
  schema: UniboExPocWeb.Schema,
  manifest: "priv/unibo/graphql/manifest.json"

config :travel, UniboExPocWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: UniboExPocWeb.ErrorHTML, json: UniboExPocWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: UniboExPoc.PubSub,
  live_view: [signing_salt: "MSGr57i3"]

config :esbuild,
  version: "0.17.11",
  travel: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.4.3",
  travel: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
