import Config

config :travel, UniboExPoc.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "travel_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :travel, UniboExPocWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4100],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "3m8H5rfD1fxvxs6Xo9pzWFOuyW+jQdldhB2MvhIm3Id8t20jhSKHP3SZ1l70hy+U",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:travel, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:travel, ~w(--watch)]}
  ]

config :travel, UniboExPocWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/unibo_ex_poc_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :travel, dev_routes: true
config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
