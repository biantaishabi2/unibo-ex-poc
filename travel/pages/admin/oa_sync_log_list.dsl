[PAGE: oa_sync_log_list]
  META: Entity("TravelOrder"), Domain("Travel")
  ATTR: Title("OA 同步日志列表")

  [SECTION: oa_sync_log_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [TEXT: oa_sync_log_title]
      ATTR: Variant("title")
      CONTENT: "{{page_title|OA 同步日志列表}}"

  [CARD: oa_sync_log_filter_card]
    [CARD_CONTENT: oa_sync_log_filter_content]
      [FLEX: oa_sync_log_filter_row]
        { Gap: 4, Align: "Center" }
        [SELECT: filter_status]
          ATTR: Name("status"), Label("状态")
          BIND: Enum("TravelOrder", "status")
        [SELECT: filter_sync_type]
          ATTR: Name("sync_type"), Label("同步类型")
        [BUTTON: oa_sync_log_filter_submit]
          ATTR: Variant("secondary"), Click("filter_submit")
          CONTENT: "查询"

  [TABLE: oa_sync_log_table]
    [TABLE_HEADER: oa_sync_log_table_header]
      [TABLE_ROW: oa_sync_log_header_row]
        [TABLE_HEAD: th_sync_time]
          CONTENT: "同步时间"
        [TABLE_HEAD: th_sync_type]
          CONTENT: "同步类型"
        [TABLE_HEAD: th_record_count]
          CONTENT: "记录数"
        [TABLE_HEAD: th_status]
          CONTENT: "状态"
        [TABLE_HEAD: th_error_message]
          CONTENT: "错误信息"
    [TABLE_BODY: oa_sync_log_table_body]
      [FOR: row in rows]
        [TABLE_ROW: oa_sync_log_row]
          [TABLE_CELL: td_sync_time]
            CONTENT: "{{row.sync_time|}}"
          [TABLE_CELL: td_sync_type]
            [BADGE: badge_sync_type]
              CONTENT: "{{row.sync_type|}}"
          [TABLE_CELL: td_record_count]
            CONTENT: "{{row.record_count|}}"
          [TABLE_CELL: td_status]
            [BADGE: badge_status]
              CONTENT: "{{row.status|}}"
          [TABLE_CELL: td_error_message]
            CONTENT: "{{row.error_message|}}"
      [/FOR]

  [IF: rows_empty]
    [EMPTY_STATE: oa_sync_log_no_data]
      ATTR: Description("暂无 OA 同步日志数据")
  [/IF]
