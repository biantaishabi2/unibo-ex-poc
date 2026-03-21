[PAGE: base_calendar]
  ATTR: Title("排期")

  [SECTION: date_nav_section]
    [FLEX: date_navigator]
      { Gap: 2, PaddingX: 3, PaddingY: 2 }
      [STACK: nav_meta]
        BIND: EntityMeta()

  [SECTION: resource_section]
    [FLEX: resource_filter]
      { Gap: 2, PaddingX: 3, PaddingY: 2, Wrap: true }
      [STACK: resource_filters]
        BIND: Filters("read")

  [SECTION: matrix_section]
    [CARD: matrix_card]
      [CARD_CONTENT: matrix_content]
        [TABLE: schedule_matrix]
          BIND: Schedule("bookings")

  [SECTION: summary_section]
    [CARD: summary_card]
      [CARD_HEADER: summary_header]
        [CARD_TITLE: summary_title]
          CONTENT: "摘要"
      [CARD_CONTENT: summary_content]
        [GRID: summary_fields]
          BIND: Fields("*")
