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
    # 认证（不暴露 GraphQL）
    UniboV4.Accounts,
    # 采购供应链
    UniboV4.Purchasing,
    UniboV4.Inventory,
    UniboV4.Uom,
    # 销售客户
    UniboV4.Sales,
    UniboV4.CRM,
    UniboV4.Ecommerce,
    UniboV4.POS,
    UniboV4.Subscriptions,
    UniboV4.Rental,
    # 财务
    UniboV4.Accounting,
    UniboV4.Expenses,
    UniboV4.Currency,
    # 生产质量
    UniboV4.Manufacturing,
    UniboV4.Maintenance,
    UniboV4.PLM,
    UniboV4.Quality,
    # 人事行政
    UniboV4.HR,
    UniboV4.Lunch,
    # 项目协作
    UniboV4.Project,
    UniboV4.Helpdesk,
    # 营销传播
    UniboV4.Marketing,
    UniboV4.Communication,
    UniboV4.LiveChat,
    # 知识内容
    UniboV4.Knowledge,
    UniboV4.Blog,
    UniboV4.Forum,
    UniboV4.Documents,
    UniboV4.Survey,
    UniboV4.Sign,
    # 在线学习
    UniboV4.ELearning,
    # 用户互动
    UniboV4.Gamification,
    UniboV4.Membership,
    # 平台工具
    UniboV4.Approvals,
    UniboV4.DataRecycle,
    UniboV4.Spreadsheet,
    UniboV4.Studio,
    UniboV4.IoT
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
