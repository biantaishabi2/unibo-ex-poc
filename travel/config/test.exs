import Config

config :travel, UniboExPoc.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
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

# Travel 域外部 API stub — 测试环境无真实外部服务，返回成功空响应
config :travel, :integration_providers, %{
  "payment_capture" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "shop_caller_context_resolve" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "shop_eligibility_quote" => fn _req -> {:ok, %{payload: %{eligible: true}, code: "stub_ok"}} end,
  "supplier_booking_submit" => fn _req -> {:ok, %{payload: %{booking_ref: "STUB-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end,
  "supplier_cancel_booking" => fn _req -> {:ok, %{payload: %{}, code: "stub_ok"}} end,
  "supplier_confirm_booking" => fn _req -> {:ok, %{payload: %{confirmation_code: "STUB-CONF-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end,
  "supplier_issue_document" => fn _req -> {:ok, %{payload: %{document_number: "STUB-DOC-#{System.unique_integer([:positive])}"}, code: "stub_ok"}} end
}
