import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :unibo_ex_poc, UniboExPoc.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "unibo_ex_poc_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 5

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :unibo_ex_poc, UniboExPocWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/EWGhveQCj71o26Lv5Rl9mdWQzhaHvpH5mDKKACZnlcKCEZ7wZ7dG3OBSyyRY3Rp",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Travel 域外部 API stub — 测试环境无真实外部服务，返回成功空响应
config :unibo_ex_poc, :integration_providers, %{
  "payment_capture" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "shop_caller_context_resolve" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "shop_eligibility_quote" => fn _req -> {:ok, %{payload: %{eligible: true}, code: "stub_ok"}} end,
  "supplier_booking_submit" => fn _req -> {:ok, %{payload: %{booking_ref: "STUB-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end,
  "supplier_cancel_booking" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "supplier_confirm_booking" => fn _req -> {:ok, %{payload: %{confirmation_code: "STUB-CONF-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end,
  "supplier_issue_document" => fn _req -> {:ok, %{payload: %{document_number: "STUB-DOC-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end
}
