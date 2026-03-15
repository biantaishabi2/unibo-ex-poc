[PAGE: travel_fulfillment_detail]
  ATTR: Title("TravelFulfillment 详情")

  [BREADCRUMB: travel_fulfillment_breadcrumb]
    [BREADCRUMB_LIST: travel_fulfillment_bc_list]
      [BREADCRUMB_ITEM: travel_fulfillment_bc_list_item]
        [BREADCRUMB_LINK: travel_fulfillment_bc_link]
          ATTR: Patch("/travel/travel_fulfillment")
          CONTENT: "TravelFulfillment 列表"
      [BREADCRUMB_SEPARATOR: travel_fulfillment_bc_sep]
      [BREADCRUMB_ITEM: travel_fulfillment_bc_current_item]
        [BREADCRUMB_PAGE: travel_fulfillment_bc_current]
          CONTENT: "{{record.supplier_booking_ref|详情}}"

  [SECTION: travel_fulfillment_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_fulfillment_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_fulfillment_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.supplier_booking_ref|}}"
      [BADGE: travel_fulfillment_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: travel_fulfillment_actions]
      { Gap: 2 }
      [BUTTON: travel_fulfillment_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"
      [BUTTON: travel_fulfillment_action_confirm_booking]
        ATTR: Variant("secondary"), Click("action_confirm_booking")
        CONTENT: "confirm_booking"
      [BUTTON: travel_fulfillment_action_issue_voucher_or_ticket]
        ATTR: Variant("secondary"), Click("action_issue_voucher_or_ticket")
        CONTENT: "issue_voucher_or_ticket"
      [BUTTON: travel_fulfillment_action_mark_in_use]
        ATTR: Variant("secondary"), Click("action_mark_in_use")
        CONTENT: "mark_in_use"
      [BUTTON: travel_fulfillment_action_complete_fulfillment]
        ATTR: Variant("secondary"), Click("action_complete_fulfillment")
        CONTENT: "complete_fulfillment"
      [BUTTON: travel_fulfillment_action_cancel_fulfillment]
        ATTR: Variant("secondary"), Click("action_cancel_fulfillment")
        CONTENT: "cancel_fulfillment"
      [BUTTON: travel_fulfillment_action_fail_fulfillment]
        ATTR: Variant("secondary"), Click("action_fail_fulfillment")
        CONTENT: "fail_fulfillment"
      [BUTTON: travel_fulfillment_delete_btn]
        ATTR: Variant("danger"), Click("action_destroy")
        CONTENT: "删除"

  [CARD: travel_fulfillment_info_card]
    [CARD_HEADER: travel_fulfillment_info_header]
      [CARD_TITLE: travel_fulfillment_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_fulfillment_info_content]
      [IF: !editing]
        [GRID: travel_fulfillment_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_tenant_id]
            [TEXT: label_tenant_id]
              ATTR: Variant("muted")
              CONTENT: "tenant_id"
            [TEXT: value_tenant_id]
              CONTENT: "{{record.tenant_id|}}"
          [FLEX: field_fulfillment_type]
            [TEXT: label_fulfillment_type]
              ATTR: Variant("muted")
              CONTENT: "fulfillment_type"
            [BADGE: value_fulfillment_type]
              CONTENT: "{{record.fulfillment_type|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "status"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
          [FLEX: field_supplier_booking_ref]
            [TEXT: label_supplier_booking_ref]
              ATTR: Variant("muted")
              CONTENT: "供应商预订号"
            [TEXT: value_supplier_booking_ref]
              CONTENT: "{{record.supplier_booking_ref|}}"
          [FLEX: field_voucher_or_ticket_ref]
            [TEXT: label_voucher_or_ticket_ref]
              ATTR: Variant("muted")
              CONTENT: "凭证号或票号"
            [TEXT: value_voucher_or_ticket_ref]
              CONTENT: "{{record.voucher_or_ticket_ref|}}"
          [FLEX: field_ticket_refs]
            [TEXT: label_ticket_refs]
              ATTR: Variant("muted")
              CONTENT: "多张票号、座席和乘客映射结果"
            [TEXT: value_ticket_refs]
              CONTENT: "{{record.ticket_refs|}}"
          [FLEX: field_waitlist_result]
            [TEXT: label_waitlist_result]
              ATTR: Variant("muted")
              CONTENT: "train 候补兑现结果"
            [BADGE: value_waitlist_result]
              CONTENT: "{{record.waitlist_result|}}"
          [FLEX: field_change_result]
            [TEXT: label_change_result]
              ATTR: Variant("muted")
              CONTENT: "train 改签结果"
            [BADGE: value_change_result]
              CONTENT: "{{record.change_result|}}"
          [FLEX: field_boarding_status]
            [TEXT: label_boarding_status]
              ATTR: Variant("muted")
              CONTENT: "train 乘车状态"
            [BADGE: value_boarding_status]
              CONTENT: "{{record.boarding_status|}}"
          [FLEX: field_confirmation_payload]
            [TEXT: label_confirmation_payload]
              ATTR: Variant("muted")
              CONTENT: "确认结果快照"
            [TEXT: value_confirmation_payload]
              CONTENT: "{{record.confirmation_payload|}}"
          [FLEX: field_failure_reason]
            [TEXT: label_failure_reason]
              ATTR: Variant("muted")
              CONTENT: "失败原因"
            [TEXT: value_failure_reason]
              CONTENT: "{{record.failure_reason|}}"
          [FLEX: field_used_at]
            [TEXT: label_used_at]
              ATTR: Variant("muted")
              CONTENT: "实际使用时间"
            [TEXT: value_used_at]
              CONTENT: "{{record.used_at|}}"
      [ELSE]
        [FORM: travel_fulfillment_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_fulfillment_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_tenant_id]
              ATTR: Name("tenant_id"), Label("tenant_id"), Placeholder("请输入tenant_id"), Required("true")
            [SELECT: form_fulfillment_type]
              ATTR: Name("fulfillment_type"), Label("fulfillment_type")
            [SELECT: form_status]
              ATTR: Name("status"), Label("status")
            [INPUT: form_supplier_booking_ref]
              ATTR: Name("supplier_booking_ref"), Label("供应商预订号"), Placeholder("请输入供应商预订号")
            [INPUT: form_voucher_or_ticket_ref]
              ATTR: Name("voucher_or_ticket_ref"), Label("凭证号或票号"), Placeholder("请输入凭证号或票号")
            [INPUT: form_ticket_refs]
              ATTR: Name("ticket_refs"), Label("多张票号、座席和乘客映射结果"), Placeholder("请输入多张票号、座席和乘客映射结果")
            [SELECT: form_waitlist_result]
              ATTR: Name("waitlist_result"), Label("train 候补兑现结果")
            [SELECT: form_change_result]
              ATTR: Name("change_result"), Label("train 改签结果")
            [SELECT: form_boarding_status]
              ATTR: Name("boarding_status"), Label("train 乘车状态")
            [TEXTAREA: form_confirmation_payload]
              ATTR: Name("confirmation_payload"), Label("确认结果快照"), Placeholder("请输入确认结果快照")
            [TEXTAREA: form_failure_reason]
              ATTR: Name("failure_reason"), Label("失败原因"), Placeholder("请输入失败原因")
            [INPUT: form_used_at]
              ATTR: Name("used_at"), Label("实际使用时间"), Placeholder("请输入实际使用时间")
          [FLEX: travel_fulfillment_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_fulfillment_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_fulfillment_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
