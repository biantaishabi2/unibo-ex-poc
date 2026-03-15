[PAGE: traveler_management]
  ATTR: Title("出行人管理")

  [SECTION: header_section]
    [FLEX: title_bar]
      { Justify: "Between", Align: "Center" }
      [TEXT: page_title]
        ATTR: Variant("h3"), Weight("bold")
        CONTENT: "出行人管理"
      [BUTTON: add_traveler_btn]
        ATTR: Variant("primary"), Size("sm"), Icon("plus"), Click("open_dialog:traveler_edit_dialog:create")
        CONTENT: "新增出行人"

  [SECTION: traveler_list_section]
    [STACK: traveler_cards]
      { Gap: 2 }
      [FOR: item in travelers]
        [CARD: traveler_card]
          [CARD_CONTENT: traveler_card_content]
            [FLEX: card_layout]
              { Justify: "Between", Align: "Center" }
              [FLEX: traveler_info]
                { Gap: 2, Align: "Center" }
                [AVATAR: traveler_avatar]
                  ATTR: Size("sm"), Fallback("{{item.full_name|}}")
                [STACK: info_lines]
                  { Gap: 0 }
                  [FLEX: name_row]
                    { Gap: 1, Align: "Center" }
                    [TEXT: traveler_name]
                      ATTR: Variant("body"), Weight("bold")
                      CONTENT: "{{item.full_name|}}"
                    [IF: item.is_self]
                      [BADGE: self_badge]
                        ATTR: Variant("secondary")
                        CONTENT: "本人"
                    [/IF]
                  [FLEX: id_row]
                    { Gap: 2 }
                    [TEXT: id_type_text]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "{{item.id_type|}}"
                    [TEXT: id_number_text]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "{{item.id_number|}}"
                  [TEXT: phone_text]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.phone|}}"
              [FLEX: card_actions]
                { Gap: 1 }
                [BUTTON: edit_btn]
                  ATTR: Variant("ghost"), Size("sm"), Icon("edit"), Click("open_dialog:traveler_edit_dialog:edit:{{item.id|}}")
                [BUTTON: delete_btn]
                  ATTR: Variant("ghost"), Size("sm"), Icon("trash"), Color("destructive"), Click("delete:Travel.TravelerProfile:{{item.id|}}")
      [/FOR]

    [IF: travelers_empty]
      [EMPTY_STATE: no_travelers]
        ATTR: Title("暂无出行人"), Description("添加常用出行人，预订时可快速选择"), Icon("users")
    [/IF]

  [SECTION: dialog_section]
    [DIALOG: traveler_edit_dialog]
      ATTR: Title("编辑出行人")
      [STACK: dialog_form]
        { Gap: 3 }
        [INPUT: input_full_name]
          ATTR: Label("姓名"), Placeholder("请输入真实姓名"), Bind("form.full_name"), Required("true")
        [SELECT: select_id_type]
          ATTR: Label("证件类型"), Placeholder("请选择证件类型"), Bind("form.id_type"), Required("true")
          CONTENT: "身份证:id_card,护照:passport,港澳通行证:hk_mo_pass,台湾通行证:tw_pass"
        [INPUT: input_id_number]
          ATTR: Label("证件号码"), Placeholder("请输入证件号码"), Bind("form.id_number"), Required("true")
        [INPUT: input_phone]
          ATTR: Label("手机号码"), Placeholder("请输入手机号码"), Bind("form.phone"), Type("tel")
        [INPUT: input_email]
          ATTR: Label("邮箱"), Placeholder("请输入邮箱地址"), Bind("form.email"), Type("email")
        [FLEX: is_self_row]
          { Justify: "Between", Align: "Center" }
          [TEXT: is_self_label]
            CONTENT: "是否本人"
          [SWITCH: switch_is_self]
            ATTR: Bind("form.is_self")
        [FLEX: dialog_actions]
          { Gap: 2, Justify: "End" }
          [BUTTON: cancel_btn]
            ATTR: Variant("outline"), Click("close_dialog:traveler_edit_dialog")
            CONTENT: "取消"
          [BUTTON: save_btn]
            ATTR: Variant("primary"), Click("submit_form:Travel.TravelerProfile")
            CONTENT: "保存"
