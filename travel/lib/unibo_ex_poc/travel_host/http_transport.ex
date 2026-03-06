defmodule UniboExPoc.TravelHost.HTTPTransport do
  @moduledoc """
  `shop` 宿主 bridge 的最小 HTTP transport。
  只负责把三类宿主能力映射到 HTTP JSON 请求，不承载业务语义。
  """

  @behaviour UniboExPoc.TravelHost.Transport

  @default_paths %{
    resolve_context: "/internal/api/travel_host_bridge/resolve_context",
    quote: "/internal/api/travel_host_bridge/quote",
    execute_payment: "/internal/api/travel_host_bridge/execute_payment"
  }

  @type response_map :: %{status: non_neg_integer(), body: binary()}

  @impl true
  def request(operation, payload, opts) when is_atom(operation) and is_map(payload) do
    with {:ok, base_url} <- fetch_base_url(opts),
         {:ok, path} <- fetch_path(operation, opts),
         {:ok, body} <- Jason.encode(payload),
         {:ok, response} <- perform_request(base_url, path, body, opts) do
      decode_response(response)
    end
  end

  def request(_operation, _payload, _opts), do: {:error, :invalid_request}

  defp fetch_base_url(opts) do
    case Keyword.get(opts, :base_url) do
      value when is_binary(value) and value != "" -> {:ok, String.trim_trailing(value, "/")}
      _other -> {:error, :missing_base_url}
    end
  end

  defp fetch_path(operation, opts) do
    path =
      opts
      |> Keyword.get(:endpoint_paths, %{})
      |> Map.get(operation, Map.fetch!(@default_paths, operation))

    case path do
      value when is_binary(value) and value != "" -> {:ok, path}
      _other -> {:error, {:missing_endpoint_path, operation}}
    end
  end

  defp perform_request(base_url, path, body, opts) do
    http_client = Keyword.get(opts, :http_client, &default_http_client/4)
    headers = build_headers(opts)
    http_opts = Keyword.get(opts, :http_options, [])

    http_client.(base_url <> path, headers, body, http_opts)
  end

  defp build_headers(opts) do
    [{"content-type", "application/json"} | normalize_headers(Keyword.get(opts, :headers, []))]
  end

  defp normalize_headers(headers) when is_list(headers) do
    Enum.map(headers, fn
      {key, value} -> {to_string(key), to_string(value)}
    end)
  end

  defp default_http_client(url, headers, body, http_opts) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    request = {String.to_charlist(url), headers, ~c"application/json", String.to_charlist(body)}

    case :httpc.request(:post, request, http_opts, body_format: :binary) do
      {:ok, {{_version, status, _reason_phrase}, _response_headers, response_body}} ->
        {:ok, %{status: status, body: response_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp decode_response(%{status: status, body: body}) when status in 200..299 do
    Jason.decode(body)
  end

  defp decode_response(%{status: status, body: body}) do
    case Jason.decode(body) do
      {:ok, %{"error" => %{"code" => code, "message" => message}}} ->
        {:error, {:host_error, status, code, message}}

      {:ok, payload} ->
        {:error, {:http_error, status, payload}}

      {:error, _reason} ->
        {:error, {:http_error, status, body}}
    end
  end
end
