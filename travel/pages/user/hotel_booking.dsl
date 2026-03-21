# 酒店预订页
# 房型摘要 + 订房信息（房间数+入住人）+ 联系人 + 支付 + 底部提交栏

[PAGE: hotel_booking]
  EXTENDS: base_booking_form
  META: Entity("HotelOffer"), Domain("Travel")

  OVERRIDE: section("summary_section")
    [CARD: hotel_summary_card]
      [CARD_HEADER: hotel_summary_ch]
        [TEXT: hotel_summary_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "房型信息"
      [CARD_CONTENT: hotel_summary_cc]
        [STACK: hotel_info_stack]
          { Gap: 2 }
          [TEXT: hotel_name]
            ATTR: Variant("h3"), Weight("bold")
            CONTENT: "{{offer.hotel_name|}}"
          [FLEX: room_badges_flex]
            { Gap: 2, Align: "Center" }
            [BADGE: room_type_badge]
              ATTR: Variant("secondary")
              CONTENT: "{{offer.room_type_ref.room_type_name|}}"
            [BADGE: bed_type_badge]
              ATTR: Variant("outline")
              CONTENT: "{{offer.room_type_ref.bed_type|}}"
          [FLEX: date_stats_flex]
            { Gap: 2 }
            [STATISTIC: checkin_stat]
              ATTR: Title("入住"), Value("{{offer.checkin_date|}}")
            [STATISTIC: checkout_stat]
              ATTR: Title("退房"), Value("{{offer.checkout_date|}}")
          [FLEX: hotel_policy_badges_flex]
            { Gap: 1, Wrap: "true" }
            [BADGE: cancellation_badge]
              ATTR: Variant("outline")
              CONTENT: "{{offer.cancellation_policy|}}"
            [BADGE: guarantee_badge]
              ATTR: Variant("outline")
              CONTENT: "{{offer.guarantee_policy|}}"
      [CARD_FOOTER: hotel_summary_cf]
        [FLEX: hotel_price_flex]
          { Justify: "End", Align: "Baseline" }
          [TEXT: hotel_currency]
            ATTR: Variant("caption")
            CONTENT: "{{offer.currency|}}"
          [TEXT: hotel_listed_price]
            ATTR: Variant("h2"), Color("primary")
            CONTENT: "{{offer.listed_price|}}"

  OVERRIDE: section("traveler_section")
    [CARD: room_info_card]
      [CARD_HEADER: room_info_ch]
        [TEXT: room_info_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "订房信息"
      [CARD_CONTENT: room_info_cc]
        [STACK: room_info_stack]
          { Gap: 3 }
          [SELECT: select_room_count]
            ATTR: Label("房间数"), Bind("form.room_count")
            CONTENT: "1间:1,2间:2,3间:3"
          [TEXT: guest_label]
            ATTR: Variant("body"), Weight("medium")
            CONTENT: "入住人"
          [STACK: guest_list_stack]
            { Gap: 2 }
            [FOR: item in travelers.items]
              [FLEX: guest_item_flex]
                { Gap: 2, Align: "Center" }
                [CHECKBOX: guest_cb]
                  ATTR: Bind("item.selected")
                [AVATAR: guest_avatar]
                  ATTR: Src("{{item.avatar|}}"), Fallback("{{item.name_initial|}}"), Size("sm")
                [STACK: guest_info_stack]
                  { Gap: 0 }
                  [TEXT: guest_name]
                    ATTR: Variant("body")
                    CONTENT: "{{item.name|}}"
                  [TEXT: guest_id_number]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.id_number_masked|}}"
            [/FOR]
          [BUTTON: btn_add_guest]
            ATTR: Variant("outline"), Size("sm"), Click("add_traveler")
            CONTENT: "+ 添加入住人"

  OVERRIDE: section("contact_section")
    [CARD: hotel_contact_card]
      [CARD_HEADER: hotel_contact_ch]
        [TEXT: hotel_contact_title]
          ATTR: Variant("h4"), Weight("bold")
          CONTENT: "联系人"
      [CARD_CONTENT: hotel_contact_cc]
        [STACK: hotel_contact_stack]
          { Gap: 3 }
          [INPUT: input_hotel_contact_name]
            ATTR: Label("联系人姓名"), Placeholder("请输入联系人姓名"), Bind("form.contact_name")
          [INPUT: input_hotel_contact_phone]
            ATTR: Label("手机号"), Placeholder("请输入手机号"), Bind("form.contact_phone")
          [INPUT: input_hotel_contact_email]
            ATTR: Label("邮箱"), Placeholder("请输入邮箱（选填）"), Bind("form.contact_email")
