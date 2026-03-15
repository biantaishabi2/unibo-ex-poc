[PAGE: flight_detail]
  META: Entity("FlightOffer"), Domain("Travel")
  ATTR: Title("航班详情")

  [SECTION: route_summary]
    { Background: "primary", Padding: 4 }
    [FLEX: route_display]
      { Justify: "Between", Align: "Center" }
      [STACK: departure_info]
        { Gap: 0, Align: "Center" }
        [TEXT: departure_time]
          ATTR: Variant("h1"), Weight("bold"), Color("white")
          CONTENT: "{{flight_offer.departure_at|}}"
        [TEXT: departure_code]
          ATTR: Variant("caption"), Color("white")
          CONTENT: "{{flight_offer.departure_airport_code|}}"
      [STACK: flight_indicator]
        { Gap: 0, Align: "Center" }
        [ICON: plane_icon]
          ATTR: Name("plane"), Color("white")
      [STACK: arrival_info]
        { Gap: 0, Align: "Center" }
        [TEXT: arrival_time]
          ATTR: Variant("h1"), Weight("bold"), Color("white")
          CONTENT: "{{flight_offer.arrival_at|}}"
        [TEXT: arrival_code]
          ATTR: Variant("caption"), Color("white")
          CONTENT: "{{flight_offer.arrival_airport_code|}}"

  [SECTION: flight_info_section]
    [CARD: flight_info_card]
      [CARD_HEADER: flight_info_header]
        [TEXT: info_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "航班信息"
      [CARD_CONTENT: flight_info_content]
        [GRID: info_grid]
          { Columns: 2, Gap: 3 }
          [TEXT: fields_display]
            BIND: Fields("flight_no", "cabin_class", "fare_family", "listed_price", "settlement_price", "currency", "seats_available", "baggage_policy", "refund_change_policy")

  [SECTION: status_section]
    [TEXT: status_display]
      BIND: Workflow("flight_offer_lifecycle")

  [SECTION: actions_section]
    [TEXT: offer_actions]
      BIND: Actions("activate", "deactivate", "expire")

  [SECTION: orders_section]
    [TEXT: orders_table]
      BIND: Relation("orders", columns: ["order_no", "product_type", "status", "total_amount", "traveler_count"])
