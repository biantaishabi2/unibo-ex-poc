import Config

db_username = System.get_env("DB_USERNAME") || "postgres"
db_password = System.get_env("DB_PASSWORD") || "postgres"
db_hostname = System.get_env("DB_HOST") || "localhost"
db_port =
  System.get_env("DB_PORT", "5432")
  |> String.to_integer()

config :travel, UniboExPoc.Repo,
  username: db_username,
  password: db_password,
  hostname: db_hostname,
  port: db_port,
  database: "travel_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 5

config :travel, UniboExPocWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4102],
  secret_key_base: "/EWGhveQCj71o26Lv5Rl9mdWQzhaHvpH5mDKKACZnlcKCEZ7wZ7dG3OBSyyRY3Rp",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true
