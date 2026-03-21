[PAGE: travel_order_detail]
  META: Entity("TravelOrder"), Domain("Travel")
  ATTR: Title("TravelOrder 详情")

  [BREADCRUMB: travel_order_breadcrumb]
    [BREADCRUMB_LIST: travel_order_bc_list]
      [BREADCRUMB_ITEM: travel_order_bc_list_item]
        [BREADCRUMB_LINK: travel_order_bc_link]
          ATTR: Patch("/travel/travel_order")
          CONTENT: "TravelOrder 列表"
      [BREADCRUMB_SEPARATOR: travel_order_bc_sep]
      [BREADCRUMB_ITEM: travel_order_bc_current_item]
        [BREADCRUMB_PAGE: travel_order_bc_current]
          CONTENT: "{{record.host_member_id|详情}}"

  [SECTION: travel_order_detail_header]
    { Direction: "Row", Justify: "Between", Align: "Center" }
    [FLEX: travel_order_title_group]
      { Gap: 3, Align: "Center" }
      [TEXT: travel_order_detail_title]
        ATTR: Variant("title")
        CONTENT: "{{record.host_member_id|}}"
      [BADGE: travel_order_status_badge]
        CONTENT: "{{record.status|}}"
    [FLEX: travel_order_actions]
      { Gap: 2 }
      [BUTTON: travel_order_edit_btn]
        ATTR: Variant("secondary"), Click("toggle_edit")
        CONTENT: "编辑"
      [BUTTON: travel_order_action_confirm_quote]
        ATTR: Variant("secondary"), Click("action_confirm_quote")
        CONTENT: "confirm_quote"
      [BUTTON: travel_order_action_submit_order]
        ATTR: Variant("secondary"), Click("action_submit_order")
        CONTENT: "submit_order"
      [BUTTON: travel_order_action_submit_waitlist]
        ATTR: Variant("secondary"), Click("action_submit_waitlist")
        CONTENT: "submit_waitlist"
      [BUTTON: travel_order_action_mark_payment_succeeded]
        ATTR: Variant("secondary"), Click("action_mark_payment_succeeded")
        CONTENT: "mark_payment_succeeded"
      [BUTTON: travel_order_action_mark_booked]
        ATTR: Variant("secondary"), Click("action_mark_booked")
        CONTENT: "mark_booked"
      [BUTTON: travel_order_action_fulfill_waitlist]
        ATTR: Variant("secondary"), Click("action_fulfill_waitlist")
        CONTENT: "fulfill_waitlist"
      [BUTTON: travel_order_action_mark_completed]
        ATTR: Variant("secondary"), Click("action_mark_completed")
        CONTENT: "mark_completed"
      [BUTTON: travel_order_action_request_cancel]
        ATTR: Variant("secondary"), Click("action_request_cancel")
        CONTENT: "request_cancel"
      [BUTTON: travel_order_action_cancel_waitlist]
        ATTR: Variant("secondary"), Click("action_cancel_waitlist")
        CONTENT: "cancel_waitlist"
      [BUTTON: travel_order_action_approve_cancel]
        ATTR: Variant("secondary"), Click("action_approve_cancel")
        CONTENT: "approve_cancel"
      [BUTTON: travel_order_action_request_change]
        ATTR: Variant("secondary"), Click("action_request_change")
        CONTENT: "request_change"
      [BUTTON: travel_order_action_confirm_change]
        ATTR: Variant("secondary"), Click("action_confirm_change")
        CONTENT: "confirm_change"
      [BUTTON: travel_order_action_mark_order_failed]
        ATTR: Variant("secondary"), Click("action_mark_order_failed")
        CONTENT: "mark_order_failed"
      [BUTTON: travel_order_delete_btn]
        ATTR: Variant("danger"), Click("action_destroy")
        CONTENT: "删除"

  [CARD: travel_order_info_card]
    [CARD_HEADER: travel_order_info_header]
      [CARD_TITLE: travel_order_info_title]
        CONTENT: "基本信息"
    [CARD_CONTENT: travel_order_info_content]
      [IF: !editing]
        [GRID: travel_order_info_grid]
          { Columns: 2, Gap: 4 }
          [FLEX: field_tenant_id]
            [TEXT: label_tenant_id]
              ATTR: Variant("muted")
              CONTENT: "tenant_id"
            [TEXT: value_tenant_id]
              CONTENT: "{{record.tenant_id|}}"
          [FLEX: field_host_shop_id]
            [TEXT: label_host_shop_id]
              ATTR: Variant("muted")
              CONTENT: "宿主商城 ID，用于 sidecar 对接上下文"
            [TEXT: value_host_shop_id]
              CONTENT: "{{record.host_shop_id|}}"
          [FLEX: field_host_member_id]
            [TEXT: label_host_member_id]
              ATTR: Variant("muted")
              CONTENT: "宿主会员标识，来自 shop caller context"
            [TEXT: value_host_member_id]
              CONTENT: "{{record.host_member_id|}}"
          [FLEX: field_host_enterprise_id]
            [TEXT: label_host_enterprise_id]
              ATTR: Variant("muted")
              CONTENT: "宿主企业标识，来自 shop caller context"
            [TEXT: value_host_enterprise_id]
              CONTENT: "{{record.host_enterprise_id|}}"
          [FLEX: field_order_no]
            [TEXT: label_order_no]
              ATTR: Variant("muted")
              CONTENT: "订单号"
            [TEXT: value_order_no]
              CONTENT: "{{record.order_no|}}"
          [FLEX: field_product_type]
            [TEXT: label_product_type]
              ATTR: Variant("muted")
              CONTENT: "商品类型"
            [BADGE: value_product_type]
              CONTENT: "{{record.product_type|}}"
          [FLEX: field_booking_mode]
            [TEXT: label_booking_mode]
              ATTR: Variant("muted")
              CONTENT: "train 订单预订模式"
            [BADGE: value_booking_mode]
              CONTENT: "{{record.booking_mode|}}"
          [FLEX: field_contact_name]
            [TEXT: label_contact_name]
              ATTR: Variant("muted")
              CONTENT: "contact_name"
            [TEXT: value_contact_name]
              CONTENT: "{{record.contact_name|}}"
          [FLEX: field_contact_phone]
            [TEXT: label_contact_phone]
              ATTR: Variant("muted")
              CONTENT: "contact_phone"
            [TEXT: value_contact_phone]
              CONTENT: "{{record.contact_phone|}}"
          [FLEX: field_traveler_count]
            [TEXT: label_traveler_count]
              ATTR: Variant("muted")
              CONTENT: "出行人数量"
            [TEXT: value_traveler_count]
              CONTENT: "{{record.traveler_count|}}"
          [FLEX: field_total_amount]
            [TEXT: label_total_amount]
              ATTR: Variant("muted")
              CONTENT: "订单总金额"
            [TEXT: value_total_amount]
              CONTENT: "{{record.total_amount|}}"
          [FLEX: field_points_to_use]
            [TEXT: label_points_to_use]
              ATTR: Variant("muted")
              CONTENT: "计划使用的积分数量"
            [TEXT: value_points_to_use]
              CONTENT: "{{record.points_to_use|}}"
          [FLEX: field_points_deduction_amount]
            [TEXT: label_points_deduction_amount]
              ATTR: Variant("muted")
              CONTENT: "积分抵现金额"
            [TEXT: value_points_deduction_amount]
              CONTENT: "{{record.points_deduction_amount|}}"
          [FLEX: field_recommended_payment_method]
            [TEXT: label_recommended_payment_method]
              ATTR: Variant("muted")
              CONTENT: "宿主 quote 返回的推荐支付方式"
            [TEXT: value_recommended_payment_method]
              CONTENT: "{{record.recommended_payment_method|}}"
          [FLEX: field_currency]
            [TEXT: label_currency]
              ATTR: Variant("muted")
              CONTENT: "currency"
            [TEXT: value_currency]
              CONTENT: "{{record.currency|}}"
          [FLEX: field_status]
            [TEXT: label_status]
              ATTR: Variant("muted")
              CONTENT: "status"
            [BADGE: value_status]
              CONTENT: "{{record.status|}}"
          [FLEX: field_change_status]
            [TEXT: label_change_status]
              ATTR: Variant("muted")
              CONTENT: "change_status"
            [BADGE: value_change_status]
              CONTENT: "{{record.change_status|}}"
          [FLEX: field_waitlist_status]
            [TEXT: label_waitlist_status]
              ATTR: Variant("muted")
              CONTENT: "waitlist_status"
            [BADGE: value_waitlist_status]
              CONTENT: "{{record.waitlist_status|}}"
          [FLEX: field_original_order_ref]
            [TEXT: label_original_order_ref]
              ATTR: Variant("muted")
              CONTENT: "改签链路引用的原订单号或原票号"
            [TEXT: value_original_order_ref]
              CONTENT: "{{record.original_order_ref|}}"
          [FLEX: field_ticket_passenger_infos]
            [TEXT: label_ticket_passenger_infos]
              ATTR: Variant("muted")
              CONTENT: "乘车人信息快照"
            [TEXT: value_ticket_passenger_infos]
              CONTENT: "{{record.ticket_passenger_infos|}}"
          [FLEX: field_seat_selection_snapshot]
            [TEXT: label_seat_selection_snapshot]
              ATTR: Variant("muted")
              CONTENT: "选座与席别偏好快照"
            [TEXT: value_seat_selection_snapshot]
              CONTENT: "{{record.seat_selection_snapshot|}}"
          [FLEX: field_supplier_order_ref]
            [TEXT: label_supplier_order_ref]
              ATTR: Variant("muted")
              CONTENT: "供应商订单号"
            [TEXT: value_supplier_order_ref]
              CONTENT: "{{record.supplier_order_ref|}}"
          [FLEX: field_payment_external_ref]
            [TEXT: label_payment_external_ref]
              ATTR: Variant("muted")
              CONTENT: "宿主支付侧外部支付流水号"
            [TEXT: value_payment_external_ref]
              CONTENT: "{{record.payment_external_ref|}}"
      [ELSE]
        [FORM: travel_order_edit_form]
          ATTR: Submit("form_submit"), Change("form_change")
          [GRID: travel_order_form_grid]
            { Columns: 2, Gap: 4 }
            [INPUT: form_tenant_id]
              ATTR: Name("tenant_id"), Label("tenant_id"), Placeholder("请输入tenant_id"), Required("true")
            [INPUT: form_host_shop_id]
              ATTR: Name("host_shop_id"), Label("宿主商城 ID，用于 sidecar 对接上下文"), Placeholder("请输入宿主商城 ID，用于 sidecar 对接上下文")
            [INPUT: form_host_member_id]
              ATTR: Name("host_member_id"), Label("宿主会员标识，来自 shop caller context"), Placeholder("请输入宿主会员标识，来自 shop caller context")
            [INPUT: form_host_enterprise_id]
              ATTR: Name("host_enterprise_id"), Label("宿主企业标识，来自 shop caller context"), Placeholder("请输入宿主企业标识，来自 shop caller context")
            [INPUT: form_order_no]
              ATTR: Name("order_no"), Label("订单号"), Placeholder("请输入订单号"), Required("true")
            [SELECT: form_product_type]
              ATTR: Name("product_type"), Label("商品类型")
              BIND: Enum("TravelOrder", "product_type")
            [SELECT: form_booking_mode]
              ATTR: Name("booking_mode"), Label("train 订单预订模式")
              BIND: Enum("TravelOrder", "booking_mode")
            [INPUT: form_contact_name]
              ATTR: Name("contact_name"), Label("contact_name"), Placeholder("请输入contact_name"), Required("true")
            [INPUT: form_contact_phone]
              ATTR: Name("contact_phone"), Label("contact_phone"), Placeholder("请输入contact_phone"), Required("true")
            [INPUT: form_traveler_count]
              ATTR: Name("traveler_count"), Label("出行人数量"), Placeholder("请输入出行人数量")
            [INPUT: form_total_amount]
              ATTR: Name("total_amount"), Label("订单总金额"), Placeholder("请输入订单总金额"), Required("true")
            [INPUT: form_points_to_use]
              ATTR: Name("points_to_use"), Label("计划使用的积分数量"), Placeholder("请输入计划使用的积分数量")
            [INPUT: form_points_deduction_amount]
              ATTR: Name("points_deduction_amount"), Label("积分抵现金额"), Placeholder("请输入积分抵现金额")
            [INPUT: form_recommended_payment_method]
              ATTR: Name("recommended_payment_method"), Label("宿主 quote 返回的推荐支付方式"), Placeholder("请输入宿主 quote 返回的推荐支付方式")
            [INPUT: form_currency]
              ATTR: Name("currency"), Label("currency"), Placeholder("请输入currency")
            [SELECT: form_status]
              ATTR: Name("status"), Label("status")
              BIND: Enum("TravelOrder", "status")
            [SELECT: form_change_status]
              ATTR: Name("change_status"), Label("change_status")
              BIND: Enum("TravelOrder", "change_status")
            [SELECT: form_waitlist_status]
              ATTR: Name("waitlist_status"), Label("waitlist_status")
              BIND: Enum("TravelOrder", "waitlist_status")
            [INPUT: form_original_order_ref]
              ATTR: Name("original_order_ref"), Label("改签链路引用的原订单号或原票号"), Placeholder("请输入改签链路引用的原订单号或原票号")
            [INPUT: form_ticket_passenger_infos]
              ATTR: Name("ticket_passenger_infos"), Label("乘车人信息快照"), Placeholder("请输入乘车人信息快照")
            [INPUT: form_seat_selection_snapshot]
              ATTR: Name("seat_selection_snapshot"), Label("选座与席别偏好快照"), Placeholder("请输入选座与席别偏好快照")
            [INPUT: form_supplier_order_ref]
              ATTR: Name("supplier_order_ref"), Label("供应商订单号"), Placeholder("请输入供应商订单号")
            [INPUT: form_payment_external_ref]
              ATTR: Name("payment_external_ref"), Label("宿主支付侧外部支付流水号"), Placeholder("请输入宿主支付侧外部支付流水号")
          [FLEX: travel_order_form_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: travel_order_cancel_btn]
              ATTR: Variant("secondary"), Click("cancel_edit")
              CONTENT: "取消"
            [BUTTON: travel_order_save_btn]
              ATTR: Variant("primary"), Click("form_submit")
              CONTENT: "保存"
      [/IF]
