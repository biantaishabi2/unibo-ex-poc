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
end
