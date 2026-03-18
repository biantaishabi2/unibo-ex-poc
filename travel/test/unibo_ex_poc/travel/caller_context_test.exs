defmodule UniboExPoc.Travel.CallerContextTest do
  use ExUnit.Case, async: true

  alias Travel.TravelHost.CallerContext

  test "可以从宿主 header 风格字段归一化 CallerContext" do
    assert {:ok, context} =
             CallerContext.normalize(%{
               "x-user-id" => "user-1",
               "x-member-id" => "member-1",
               "x-enterprise-id" => "ent-1",
               "x-shop-id" => "shop-1",
               "x-request-id" => "req-1",
               "x-roles" => "buyer,travel"
             })

    assert context.user_id == "user-1"
    assert context.member_id == "member-1"
    assert context.enterprise_id == "ent-1"
    assert context.current_shop_id == "shop-1"
    assert context.request_id == "req-1"
    assert context.roles == ["buyer", "travel"]
  end
end
