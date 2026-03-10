defmodule UniboExPoc.Travel.GraphqlPrimaryPathTest do
  use UniboExPocWeb.ConnCase, async: false

  alias UniboExPoc.Repo
  alias Ecto.Adapters.SQL

  @tenant_id "00000000-0000-0000-0000-000000000001"

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

  test "GraphQL 主路径可完成 flight/vacation/train 订单闭环", %{conn: conn} do
    customer_id = insert_customer_fixture!()
    suffix = System.unique_integer([:positive]) |> Integer.to_string()

    scenarios = [
      %{
        kind: "flight",
        create_offer_mutation: """
        mutation($input: CreateTravelFlightOfferInput!) {
          createTravelFlightOffer(input: $input) {
            errors { message fields }
            result { id }
          }
        }
        """,
        offer_payload: %{
          "arrivalAirportCode" => "PVG",
          "arrivalAt" => "2026-04-01T10:30:00Z",
          "cabinClass" => "economy",
          "departureAirportCode" => "SHA",
          "departureAt" => "2026-04-01T08:00:00Z",
          "flightNo" => "MU#{suffix}",
          "itineraryCode" => "FLT#{suffix}",
          "listedPrice" => "880.00",
          "supplierCode" => "SUPP-FLT-#{suffix}",
          "tenantId" => @tenant_id
        },
        offer_root: "createTravelFlightOffer",
        order_payload: fn offer_id ->
          %{
            "contactName" => "Flight Tester",
            "contactPhone" => "13800001111",
            "customerId" => customer_id,
            "flightOfferId" => offer_id,
            "orderNo" => "ORD-FLT-#{suffix}",
            "productType" => "flight",
            "tenantId" => @tenant_id,
            "totalAmount" => "880.00"
          }
        end,
        expected_offer_fields: %{
          "flightOfferId" => :present,
          "vacationOfferId" => :nil,
          "trainOfferId" => :nil,
          "hotelOfferId" => :nil
        }
      },
      %{
        kind: "vacation",
        create_offer_mutation: """
        mutation($input: CreateTravelVacationOfferInput!) {
          createTravelVacationOffer(input: $input) {
            errors { message fields }
            result { id }
          }
        }
        """,
        offer_payload: %{
          "departureCityCode" => "SHA",
          "destinationCode" => "HKG",
          "endDate" => "2026-05-05",
          "listedPrice" => "2888.00",
          "packageCode" => "VAC#{suffix}",
          "packageName" => "Mock Vacation #{suffix}",
          "startDate" => "2026-05-01",
          "supplierCode" => "SUPP-VAC-#{suffix}",
          "tenantId" => @tenant_id
        },
        offer_root: "createTravelVacationOffer",
        order_payload: fn offer_id ->
          %{
            "contactName" => "Vacation Tester",
            "contactPhone" => "13800002222",
            "customerId" => customer_id,
            "orderNo" => "ORD-VAC-#{suffix}",
            "productType" => "vacation",
            "tenantId" => @tenant_id,
            "totalAmount" => "2888.00",
            "vacationOfferId" => offer_id
          }
        end,
        expected_offer_fields: %{
          "flightOfferId" => :nil,
          "vacationOfferId" => :present,
          "trainOfferId" => :nil,
          "hotelOfferId" => :nil
        }
      },
      %{
        kind: "train",
        create_offer_mutation: """
        mutation($input: CreateTravelTrainOfferInput!) {
          createTravelTrainOffer(input: $input) {
            errors { message fields }
            result { id }
          }
        }
        """,
        offer_payload: %{
          "arrivalAt" => "2026-06-01T11:30:00Z",
          "arrivalStationCode" => "NJ",
          "arrivalStationName" => "Nanjing",
          "departureAt" => "2026-06-01T09:00:00Z",
          "departureStationCode" => "SH",
          "departureStationName" => "Shanghai",
          "listedPrice" => "188.00",
          "seatClass" => "second_class",
          "seatCode" => "ZE",
          "supplierCode" => "SUPP-TRN-#{suffix}",
          "tenantId" => @tenant_id,
          "trainNo" => "G#{suffix}",
          "travelDate" => "2026-06-01"
        },
        offer_root: "createTravelTrainOffer",
        order_payload: fn offer_id ->
          %{
            "contactName" => "Train Tester",
            "contactPhone" => "13800003333",
            "customerId" => customer_id,
            "orderNo" => "ORD-TRN-#{suffix}",
            "productType" => "train",
            "tenantId" => @tenant_id,
            "totalAmount" => "188.00",
            "trainOfferId" => offer_id
          }
        end,
        expected_offer_fields: %{
          "flightOfferId" => :nil,
          "vacationOfferId" => :nil,
          "trainOfferId" => :present,
          "hotelOfferId" => :nil
        }
      }
    ]

    create_order_mutation = """
    mutation($input: CreateCreateOrderTravelTravelOrderInput!) {
      createCreateOrderTravelTravelOrder(input: $input) {
        errors { message fields }
        result {
          id
          status
          productType
          paymentId
          supplierOrderRef
          hotelOfferId
          flightOfferId
          vacationOfferId
          trainOfferId
        }
      }
    }
    """

    confirm_order_mutation = """
    mutation($id: ID!) {
      confirmQuoteTravelTravelOrder(id: $id) {
        errors { message fields }
        result {
          id
          status
          productType
          paymentId
          supplierOrderRef
        }
      }
    }
    """

    submit_order_mutation = """
    mutation($id: ID!) {
      submitOrderTravelTravelOrder(id: $id) {
        errors { message fields }
        result {
          id
          status
          productType
          paymentId
          supplierOrderRef
        }
      }
    }
    """

    Enum.each(scenarios, fn scenario ->
      offer =
        conn
        |> travel_conn()
        |> graphql(scenario.create_offer_mutation, %{"input" => scenario.offer_payload})
        |> fetch_result!(scenario.offer_root)

      order =
        conn
        |> travel_conn()
        |> graphql(create_order_mutation, %{"input" => scenario.order_payload.(offer["id"])})
        |> fetch_result!("createCreateOrderTravelTravelOrder")

      assert order["status"] == "draft"
      assert order["productType"] == scenario.kind

      Enum.each(scenario.expected_offer_fields, fn
        {field, :present} -> assert is_binary(order[field])
        {field, :nil} -> assert is_nil(order[field])
      end)

      quoted =
        conn
        |> travel_conn()
        |> graphql(confirm_order_mutation, %{"id" => order["id"]})
        |> fetch_result!("confirmQuoteTravelTravelOrder")

      assert quoted["status"] == "quoted"
      assert quoted["productType"] == scenario.kind

      submitted =
        conn
        |> travel_conn()
        |> graphql(submit_order_mutation, %{"id" => order["id"]})
        |> fetch_result!("submitOrderTravelTravelOrder")

      assert submitted["status"] == "submitted"
      assert submitted["productType"] == scenario.kind
    end)
  end

  defp graphql(conn, query, variables \\ %{}) do
    conn
    |> post("/api/graphql", %{query: query, variables: variables})
    |> json_response(200)
  end

  defp fetch_result!(resp, root_key) do
    payload = get_in(resp, ["data", root_key])
    assert payload["errors"] == []
    refute is_nil(payload["result"])
    payload["result"]
  end

  defp travel_conn(conn) do
    conn
    |> put_req_header("x-tenant-id", @tenant_id)
    |> put_req_header("x-actor-id", "tester-1")
    |> put_req_header("x-actor-role", "admin")
  end

  defp insert_customer_fixture! do
    customer_id = Ecto.UUID.generate()
    customer_code = "CUST-GQL-#{System.unique_integer([:positive])}"

    SQL.query!(
      Repo,
      """
      insert into sales_customers (id, customer_code, name, status, customer_type)
      values (($1)::text::uuid, $2, $3, 'active', 'company')
      """,
      [customer_id, customer_code, "GraphQL Customer #{customer_code}"]
    )

    customer_id
  end
end
