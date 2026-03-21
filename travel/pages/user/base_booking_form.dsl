# 预订表单基础模板
# 共有骨架：导航 → 摘要卡片 → 差标提示 → 出行人 → 联系人 → 支付方式 → 底部提交栏

[PAGE: base_booking_form]
  ATTR: Title("填写订单")

  # 顶部导航
  [SECTION: header_section]
    [HEADER: page_header]
      ATTR: Back("true"), Title("填写订单")

  # 产品摘要 — 子页面 OVERRIDE
  [SECTION: summary_section]
    [CARD: summary_card]
      [CARD_CONTENT: summary_cc]
        [TEXT: summary_placeholder]
          CONTENT: "产品摘要（由子页面覆写）"

  # 差标提示 — 子页面按需 OVERRIDE
  [SECTION: policy_alert_section]

  # 出行人 — 子页面 OVERRIDE
  [SECTION: traveler_section]
    [CARD: traveler_card]
      [CARD_HEADER: traveler_ch]
        [FLEX: traveler_header_flex]
          { Justify: "Between", Align: "Center" }
          [TEXT: traveler_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "出行人"
          [BUTTON: btn_add_traveler]
            ATTR: Variant("ghost"), Size("sm"), Click("add_traveler")
            CONTENT: "+ 添加"
      [CARD_CONTENT: traveler_cc]
        [STACK: traveler_list_stack]
          { Gap: 2 }
          [FOR: item in travelers.items]
            [FLEX: traveler_item_flex]
              { Gap: 2, Align: "Center" }
              [CHECKBOX: traveler_cb]
                ATTR: Bind("item.selected")
              [AVATAR: traveler_avatar]
                ATTR: Src("{{item.avatar|}}"), Fallback("{{item.name_initial|}}"), Size("sm")
              [STACK: traveler_info_stack]
                { Gap: 0 }
                [TEXT: traveler_name]
                  ATTR: Variant("body")
                  CONTENT: "{{item.name|}}"
                [TEXT: traveler_id_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{item.id_type_label|}}"
          [/FOR]

  # 联系人
  [SECTION: contact_section]
    [CARD: contact_card]
      [CARD_HEADER: contact_ch]
        [TEXT: contact_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "联系人"
      [CARD_CONTENT: contact_cc]
        [STACK: contact_stack]
          { Gap: 3 }
          [INPUT: input_contact_name]
            ATTR: Label("联系人姓名"), Placeholder("请输入联系人姓名"), Bind("form.contact_name")
          [INPUT: input_contact_phone]
            ATTR: Label("手机号"), Placeholder("请输入手机号"), Bind("form.contact_phone")

  # 额外选项 — 子页面按需 OVERRIDE
  [SECTION: extra_options_section]

  # 支付方式
  [SECTION: payment_section]
    [CARD: payment_card]
      [CARD_HEADER: payment_ch]
        [TEXT: payment_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "支付方式"
      [CARD_CONTENT: payment_cc]
        [SELECT: select_payment_method]
          ATTR: Label("选择支付方式"), Bind("form.payment_method")
          CONTENT: "企业支付:corporate,个人支付:personal"

  # 底部提交栏
  [SECTION: submit_bar_section]
    [CONTROLBAR: submit_bar]
      ATTR: Position("sticky_bottom")
      [FLEX: submit_bar_flex]
        { Justify: "Between", Align: "Center" }
        [FLEX: price_flex]
          { Gap: 1, Align: "Baseline" }
          [TEXT: total_label]
            ATTR: Variant("caption")
            CONTENT: "合计"
          [TEXT: total_currency]
            ATTR: Variant("caption"), Color("primary")
            CONTENT: "{{offer.currency|}}"
          [TEXT: total_price]
            ATTR: Variant("h2"), Color("primary")
            CONTENT: "{{offer.total_price|}}"
        [BUTTON: btn_submit]
          ATTR: Variant("primary"), Size("lg"), Click("submit_booking")
          CONTENT: "提交订单"
