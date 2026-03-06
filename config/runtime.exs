import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/unibo_ex_poc start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :unibo_ex_poc, UniboExPocWeb.Endpoint, server: true
end

shop_bridge_config = Application.get_env(:unibo_ex_poc, :travel_host_shop_bridge, [])

shop_bridge_base_url =
  case System.get_env("SHOP_BRIDGE_BASE_URL") do
    value when is_binary(value) and value != "" -> value
    _other -> Keyword.get(shop_bridge_config, :base_url)
  end

if is_binary(shop_bridge_base_url) and shop_bridge_base_url != "" do
  shop_bridge_headers_from_env =
    System.get_env("SHOP_BRIDGE_HEADERS", "")
    |> String.split(",", trim: true)
    |> Enum.reduce([], fn pair, acc ->
      case String.split(pair, "=", parts: 2) do
        [raw_key, value] ->
          key = String.trim(raw_key)

          if key == "" do
            acc
          else
            [{key, String.trim(value)} | acc]
          end

        [raw_key] ->
          key = String.trim(raw_key)

          if key == "" do
            acc
          else
            [{key, ""} | acc]
          end

        _other ->
          acc
      end
    end)
    |> Enum.reverse()

  shop_bridge_headers =
    Keyword.get(shop_bridge_config, :headers, []) ++ shop_bridge_headers_from_env

  shop_bridge_endpoint_paths = Keyword.get(shop_bridge_config, :endpoint_paths, %{})
  shop_bridge_http_options = Keyword.get(shop_bridge_config, :http_options, [])

  shop_bridge_bridge_client =
    Keyword.get(shop_bridge_config, :bridge_client, UniboExPoc.TravelHost.ShopBridgeClient)

  shop_bridge_transport =
    Keyword.get(shop_bridge_config, :transport, UniboExPoc.TravelHost.HTTPTransport)

  config :unibo_ex_poc, :travel_host_shop_bridge,
    bridge_client: shop_bridge_bridge_client,
    transport: shop_bridge_transport,
    base_url: shop_bridge_base_url,
    endpoint_paths: shop_bridge_endpoint_paths,
    headers: shop_bridge_headers,
    http_options: shop_bridge_http_options

  config :unibo_ex_poc,
         :travel_host_bridge,
         {shop_bridge_bridge_client,
          transport: shop_bridge_transport,
          transport_opts: [
            base_url: shop_bridge_base_url,
            endpoint_paths: shop_bridge_endpoint_paths,
            headers: shop_bridge_headers,
            http_options: shop_bridge_http_options
          ]}
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :unibo_ex_poc, UniboExPoc.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :unibo_ex_poc, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :unibo_ex_poc, UniboExPocWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :unibo_ex_poc, UniboExPocWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :unibo_ex_poc, UniboExPocWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
