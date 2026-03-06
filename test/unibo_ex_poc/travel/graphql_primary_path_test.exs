defmodule UniboExPoc.Travel.GraphqlPrimaryPathTest do
  use UniboExPocWeb.ConnCase, async: false

  test "GraphQL schema 稳定暴露 travel 查询与变更字段", %{conn: conn} do
    introspection = """
    query {
      __schema {
        queryType { fields { name } }
        mutationType { fields { name } }
      }
    }
    """

    resp = graphql(conn, introspection)

    query_fields =
      get_in(resp, ["data", "__schema", "queryType", "fields"])
      |> Enum.map(& &1["name"])

    mutation_fields =
      get_in(resp, ["data", "__schema", "mutationType", "fields"])
      |> Enum.map(& &1["name"])

    assert "listTravelHotelOffers" in query_fields
    assert "listTravelTravelOrders" in query_fields
    assert "createTravelHotelOffer" in mutation_fields
  end

  test "GraphQL 主路径包含 travel 资源类型与分页查询参数（不依赖 HotelFlow）", %{conn: conn} do
    introspection = """
    query {
      __type(name: "TravelHotelOffer") {
        name
        fields { name }
      }
      __schema {
        queryType {
          fields {
            name
            args { name }
          }
        }
      }
    }
    """

    resp = graphql(conn, introspection)

    hotel_offer_fields =
      get_in(resp, ["data", "__type", "fields"])
      |> Enum.map(& &1["name"])

    assert "hotelCode" in hotel_offer_fields
    assert "supplierCode" in hotel_offer_fields

    list_travel_hotel_offers_field =
      get_in(resp, ["data", "__schema", "queryType", "fields"])
      |> Enum.find(&(&1["name"] == "listTravelHotelOffers"))

    query_args = list_travel_hotel_offers_field["args"] |> Enum.map(& &1["name"])
    assert "first" in query_args
    assert "filter" in query_args
  end

  defp graphql(conn, query, variables \\ %{}) do
    conn
    |> post("/api/graphql", %{query: query, variables: variables})
    |> json_response(200)
  end
end
