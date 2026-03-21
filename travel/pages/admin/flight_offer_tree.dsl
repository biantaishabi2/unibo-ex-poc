[PAGE: flight_offer_tree]
  EXTENDS: base_list_report
  META: Entity("FlightOffer"), Domain("Travel")

  OVERRIDE: section("filter_section")
    [CARD: filter_card]
      [CARD_CONTENT: filter_content]
        [FLEX: filter_row]
          { Gap: 4, Align: "Center" }
          [INPUT: filter_departure_at]
            ATTR: Name("departure_at_from"), Label("起飞时间 起")
          [SELECT: filter_sale_status]
            ATTR: Name("sale_status"), Label("销售状态")
            BIND: Enum("FlightOffer", "sale_status")
          [BUTTON: filter_submit]
            ATTR: Variant("secondary"), Click("filter_submit")
            CONTENT: "查询"

  OVERRIDE: section("table_section")
    [SPLIT: main_split]
      ATTR: Ratio("1:3")
      [STACK: left_panel]
        [TREE: airline_tree]
          CONTENT: "按航空公司分组"
      [STACK: right_panel]
        KEEP: section("table_section")
