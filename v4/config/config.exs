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
  # 仅保留手写域；编译器生成的域在 application.ex 启动时动态合并
  ash_domains: [
    UniboV4.Accounts
  ]

# 允许编译器生成的域模块不在 config 中列出（运行时动态注册）
config :ash, :validate_domain_config_inclusion?, false

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
