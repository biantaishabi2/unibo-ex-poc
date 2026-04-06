import Config

config :travel, UniboExPoc.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: System.get_env("TRAVEL_DEV_DB") || "travel_dev",
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

# 开发环境默认 tenant（multitenancy 实体页面验证用）
config :travel, UniboExPocWeb.Graphql.RuntimeConfig,
  default_tenant_id: "00000000-0000-0000-0000-000000000001",
  require_actor_for_mutation: false

# Travel 域外部 API stub — 开发环境无真实外部服务，返回成功空响应
config :travel, :integration_providers, %{
  "payment_capture" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "shop_caller_context_resolve" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "shop_eligibility_quote" => fn _req -> {:ok, %{payload: %{eligible: true}, code: "stub_ok"}} end,
  "supplier_booking_submit" => fn _req -> {:ok, %{payload: %{booking_ref: "STUB-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end,
  "supplier_cancel_booking" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "supplier_confirm_booking" => fn _req -> {:ok, %{payload: %{confirmation_code: "STUB-CONF-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end,
  "supplier_issue_document" => fn _req -> {:ok, %{payload: %{document_number: "STUB-DOC-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end
}
