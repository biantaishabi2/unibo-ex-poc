defmodule UniboExPoc.Travel.HTTPTransportTest do
  use ExUnit.Case, async: true

  alias UniboExPoc.TravelHost.HTTPTransport

  test "request 会把操作映射到宿主 endpoint 并解析 JSON 响应" do
    payload = %{caller_context: %{user_id: "user-1"}}

    assert {:ok, %{"caller_context" => %{"user_id" => "user-1"}}} =
             HTTPTransport.request(
               :resolve_context,
               payload,
               base_url: "http://shop.local",
               http_client: fn url, headers, body, _http_opts ->
                 assert url == "http://shop.local/internal/api/travel_host_bridge/resolve_context"
                 assert {"content-type", "application/json"} in headers
                 assert Jason.decode!(body) == %{"caller_context" => %{"user_id" => "user-1"}}

                 {:ok,
                  %{
                    status: 200,
                    body: ~s({"caller_context":{"user_id":"user-1"}})
                  }}
               end
             )
  end

  test "request 会把宿主错误响应映射为 host_error" do
    assert {:error, {:host_error, 403, "access_denied", "forbidden"}} =
             HTTPTransport.request(
               :quote,
               %{},
               base_url: "http://shop.local",
               http_client: fn _url, _headers, _body, _http_opts ->
                 {:ok,
                  %{
                    status: 403,
                    body: ~s({"error":{"code":"access_denied","message":"forbidden"}})
                  }}
               end
             )
  end

  test "request 支持 endpoint_paths 覆盖并透传 http_options" do
    assert {:ok, %{"payment_execution" => %{"status" => "approved"}}} =
             HTTPTransport.request(
               :execute_payment,
               %{payment_request: %{method: "mixed"}},
               base_url: "http://shop.local",
               endpoint_paths: %{execute_payment: "/internal/travel_bridge/pay"},
               http_options: [timeout: 3_000],
               http_client: fn url, _headers, body, http_opts ->
                 assert url == "http://shop.local/internal/travel_bridge/pay"
                 assert Jason.decode!(body) == %{"payment_request" => %{"method" => "mixed"}}
                 assert http_opts == [timeout: 3_000]

                 {:ok,
                  %{
                    status: 200,
                    body: ~s({"payment_execution":{"status":"approved"}})
                  }}
               end
             )
  end
end
