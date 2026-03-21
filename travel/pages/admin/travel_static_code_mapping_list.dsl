[PAGE: travel_static_code_mapping_list]
  META: Entity("TravelStaticCodeMapping"), Domain("Travel")
  ATTR: Title("TravelStaticCodeMapping 列表")

  [SECTION: travel_static_code_mapping_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: travel_static_code_mapping_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|TravelStaticCodeMapping 列表}}"
    [BUTTON: travel_static_code_mapping_create_btn]
      ATTR: Variant("primary"), Click("navigate_create")
      CONTENT: "新建"

  [CARD: travel_static_code_mapping_filter_card]
    [CARD_CONTENT: travel_static_code_mapping_filter_content]
      [FLEX: travel_static_code_mapping_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_object_type]
          ATTR: Name("object_type"), Label("主数据对象类型")
        [SELECT: filter_status]
          ATTR: Name("status"), Label("status")
        [BUTTON: travel_static_code_mapping_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: travel_static_code_mapping_table]
    BIND: Fields("*")
    [TABLE_HEADER: travel_static_code_mapping_table_header]
      [TABLE_ROW: travel_static_code_mapping_header_row]
        [TABLE_HEAD: th_supplier_code]
          CONTENT: "供应商编码"
        [TABLE_HEAD: th_object_type]
          CONTENT: "主数据对象类型"
        [TABLE_HEAD: th_canonical_entity]
          CONTENT: "Travel 实体名"
        [TABLE_HEAD: th_canonical_id]
          CONTENT: "Travel 实体 ID"
        [TABLE_HEAD: th_external_code]
          CONTENT: "供应商侧编码"
        [TABLE_HEAD: th_external_name]
          CONTENT: "供应商侧名称"
        [TABLE_HEAD: th_status]
          CONTENT: "status"
    [TABLE_BODY: travel_static_code_mapping_table_body]
      [FOR: row in rows]
        [TABLE_ROW: travel_static_code_mapping_row]
          [TABLE_CELL: td_supplier_code]
            CONTENT: "{{row.supplier_code|}}"
          [TABLE_CELL: td_object_type]
            [BADGE: badge_object_type]
              CONTENT: "{{row.object_type|}}"
          [TABLE_CELL: td_canonical_entity]
            CONTENT: "{{row.canonical_entity|}}"
          [TABLE_CELL: td_canonical_id]
            CONTENT: "{{row.canonical_id|}}"
          [TABLE_CELL: td_external_code]
            CONTENT: "{{row.external_code|}}"
          [TABLE_CELL: td_external_name]
            CONTENT: "{{row.external_name|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: travel_static_code_mapping_no_data]
      ATTR: Description("暂无供应商静态码到 Travel 主数据的映射（Travel 层统一适配）数据")
  [/IF]
