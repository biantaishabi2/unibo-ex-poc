defmodule UniboV4Web.ErrorJSONTest do
  use UniboV4Web.ConnCase, async: true

  test "renders 404" do
    assert UniboV4Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert UniboV4Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
