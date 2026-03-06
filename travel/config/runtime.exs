import Config

if System.get_env("PHX_SERVER") do
  config :travel, UniboExPocWeb.Endpoint, server: true
end

shop_bridge_config = Application.get_env(:travel, :travel_host_shop_bridge, [])

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

  config :travel, :travel_host_shop_bridge,
    bridge_client: shop_bridge_bridge_client,
    transport: shop_bridge_transport,
    base_url: shop_bridge_base_url,
    endpoint_paths: shop_bridge_endpoint_paths,
    headers: shop_bridge_headers,
    http_options: shop_bridge_http_options

  config :travel,
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

  config :travel, UniboExPoc.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :travel, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :travel, UniboExPocWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base
end
