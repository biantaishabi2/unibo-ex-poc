[PAGE: base_modal_dialog]
  ATTR: Title("模态对话框")

  [SECTION: confirm_dialog]
    [CARD: confirm_card]
      [CARD_HEADER: confirm_header]
        [CARD_TITLE: confirm_title]
          CONTENT: "{{confirm_title|确认操作}}"
      [CARD_CONTENT: confirm_content]
        [STACK: confirm_layout]
          { Gap: 4 }
          [TEXT: confirm_message]
            CONTENT: "{{confirm_message|确定要执行此操作吗？}}"
          [TEXT: confirm_description]
            ATTR: Variant("body"), Color("muted")
            CONTENT: "{{confirm_description|此操作不可撤销，请谨慎确认。}}"
          [FLEX: confirm_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: confirm_cancel_btn]
              ATTR: Variant("secondary"), Click("dialog_cancel")
              CONTENT: "取消"
            [BUTTON: confirm_ok_btn]
              ATTR: Variant("primary"), Click("dialog_confirm")
              CONTENT: "确定"

  [SECTION: form_dialog]
    [CARD: form_dialog_card]
      [CARD_HEADER: form_dialog_header]
        [CARD_TITLE: form_dialog_title]
          CONTENT: "{{form_dialog_title|表单对话框}}"
      [CARD_CONTENT: form_dialog_content]
        [FORM: dialog_form]
          ATTR: Submit("dialog_form_submit"), Change("dialog_form_change")
          [STACK: form_fields]
            { Gap: 3 }
            [INPUT: dialog_field_1]
              ATTR: Name("field_1"), Label("字段一"), Placeholder("请输入"), Required("true")
            [INPUT: dialog_field_2]
              ATTR: Name("field_2"), Label("字段二"), Placeholder("请输入")
            [TEXTAREA: dialog_field_3]
              ATTR: Name("reason"), Label("备注"), Placeholder("请输入备注信息")
          [FLEX: form_dialog_actions]
            { Justify: "End", Gap: 2 }
            [BUTTON: form_dialog_cancel]
              ATTR: Variant("secondary"), Click("dialog_cancel")
              CONTENT: "取消"
            [BUTTON: form_dialog_submit]
              ATTR: Variant("primary"), Click("dialog_form_submit")
              CONTENT: "确认提交"

  [SECTION: info_dialog]
    [CARD: info_dialog_card]
      [CARD_HEADER: info_dialog_header]
        [CARD_TITLE: info_dialog_title]
          CONTENT: "{{info_dialog_title|详情}}"
      [CARD_CONTENT: info_dialog_content]
        [STACK: info_layout]
          { Gap: 3 }
          [GRID: info_grid]
            { Columns: 2, Gap: 3 }
            [STACK: info_item_1]
              { Gap: 1 }
              [TEXT: info_label_1]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{info_label_1|标签一}}"
              [TEXT: info_value_1]
                CONTENT: "{{info_value_1|}}"
            [STACK: info_item_2]
              { Gap: 1 }
              [TEXT: info_label_2]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{info_label_2|标签二}}"
              [TEXT: info_value_2]
                CONTENT: "{{info_value_2|}}"
            [STACK: info_item_3]
              { Gap: 1 }
              [TEXT: info_label_3]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{info_label_3|标签三}}"
              [TEXT: info_value_3]
                CONTENT: "{{info_value_3|}}"
            [STACK: info_item_4]
              { Gap: 1 }
              [TEXT: info_label_4]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{info_label_4|标签四}}"
              [TEXT: info_value_4]
                CONTENT: "{{info_value_4|}}"
          [FLEX: info_dialog_actions]
            { Justify: "End" }
            [BUTTON: info_dialog_close]
              ATTR: Variant("secondary"), Click("dialog_close")
              CONTENT: "关闭"
