[PAGE: order_detail]
  ATTR: Title("订单详情")

  [SECTION: main_content]
    { Padding: 3 }
    [STACK: content_stack]
      { Gap: 3 }

      [CARD: status_card]
        [CARD_CONTENT: status_content]
          [FLEX: status_flex]
            { Gap: 2, Direction: "Column", Align: "Center", Padding: 3 }
            [IF: order_status_booked_or_completed]
              [ICON: success_icon]
                ATTR: Name("check-circle"), Size("lg"), Color("success")
            [/IF]
            [IF: order_pending]
              [ICON: pending_icon]
                ATTR: Name("clock"), Size("lg"), Color("warning")
            [/IF]
            [IF: order_cancelled_or_failed]
              [ICON: fail_icon]
                ATTR: Name("x-circle"), Size("lg"), Color("destructive")
            [/IF]
            [TEXT: status_text]
              ATTR: Variant("h2"), Weight("bold")
              CONTENT: "{{order.status|}}"
            [IF: order_status_completed]
              [TEXT: completed_hint]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "订单已完成，感谢您的使用"
            [/IF]

      [CARD: order_info_card]
        [CARD_HEADER: order_info_header]
          [TEXT: order_info_title]
            ATTR: Variant("h4"), Weight("bold")
            CONTENT: "订单信息"
        [CARD_CONTENT: order_info_content]
          [STACK: order_info_stack]
            { Gap: 2 }
            [FLEX: order_no_row]
              { Justify: "Between" }
              [TEXT: order_no_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "订单号"
              [TEXT: order_no_value]
                CONTENT: "{{order.order_no|}}"
            [SEPARATOR: info_sep_1]
            [FLEX: total_amount_row]
              { Justify: "Between" }
              [TEXT: total_amount_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "总金额"
              [TEXT: total_amount_value]
                ATTR: Variant("h3")
                CONTENT: "{{order.total_amount|}}"
            [IF: has_points_deduction]
              [FLEX: points_row]
                { Justify: "Between" }
                [TEXT: points_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "积分抵扣"
                [TEXT: points_value]
                  CONTENT: "{{order.points_deduction_amount|}}"
            [/IF]
            [FLEX: payable_row]
              { Justify: "Between" }
              [TEXT: payable_label]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "应付金额"
              [TEXT: payable_value]
                ATTR: Variant("h3"), Color("primary")
                CONTENT: "{{order.payable_amount|}}"

      [IF: is_flight_order]
        [CARD: flight_info_card]
          [CARD_HEADER: flight_info_header]
            [TEXT: flight_info_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "航班信息"
          [CARD_CONTENT: flight_info_content]
            [STACK: flight_info_stack]
              { Gap: 3 }
              [FLEX: flight_route_row]
                { Justify: "Between", Align: "Center" }
                [STACK: flight_dep]
                  { Gap: 0, Align: "Center" }
                  [TEXT: flight_dep_time]
                    ATTR: Variant("h2"), Weight("bold")
                    CONTENT: "{{order.flight_offer.departure_time|}}"
                  [TEXT: flight_dep_airport]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.flight_offer.departure_airport|}}"
                  [TEXT: flight_dep_terminal]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.flight_offer.departure_terminal|}}"
                [STACK: flight_mid]
                  { Gap: 0, Align: "Center" }
                  [TEXT: flight_duration]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.flight_offer.duration|}}"
                  [ICON: flight_arrow]
                    ATTR: Name("arrow-right"), Size("sm")
                  [TEXT: flight_no_mid]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.flight_offer.flight_no|}}"
                [STACK: flight_arr]
                  { Gap: 0, Align: "Center" }
                  [TEXT: flight_arr_time]
                    ATTR: Variant("h2"), Weight("bold")
                    CONTENT: "{{order.flight_offer.arrival_time|}}"
                  [TEXT: flight_arr_airport]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.flight_offer.arrival_airport|}}"
                  [TEXT: flight_arr_terminal]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.flight_offer.arrival_terminal|}}"
              [SEPARATOR: flight_sep_1]
              [FLEX: airline_info_row]
                { Gap: 2, Wrap: "true" }
                [TEXT: airline_name]
                  ATTR: Variant("caption")
                  CONTENT: "{{order.flight_offer.airline_name|}}"
                [TEXT: aircraft_type]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "{{order.flight_offer.aircraft_type|}}"
                [BADGE: meal_badge]
                  ATTR: Variant("secondary")
                  CONTENT: "{{order.flight_offer.meal_info|}}"
              [SEPARATOR: flight_sep_2]
              [TEXT: refund_policy]
                ATTR: Variant("caption")
                CONTENT: "{{order.flight_offer.refund_change_policy|}}"
              [TEXT: baggage_policy]
                ATTR: Variant("caption")
                CONTENT: "{{order.flight_offer.baggage_allowance|}}"
              [TEXT: product_desc]
                ATTR: Variant("caption")
                CONTENT: "{{order.flight_offer.product_description|}}"
      [/IF]

      [IF: is_train_order]
        [CARD: train_info_card]
          [CARD_HEADER: train_info_header]
            [TEXT: train_info_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "车次信息"
          [CARD_CONTENT: train_info_content]
            [STACK: train_info_stack]
              { Gap: 3 }
              [FLEX: pickup_gate_row]
                { Gap: 3 }
                [FLEX: pickup_row]
                  { Gap: 1 }
                  [TEXT: pickup_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "取票号"
                  [TEXT: pickup_value]
                    ATTR: Variant("body"), Weight("bold")
                    CONTENT: "{{order.seat_selection_snapshot.pickup_code|}}"
                [FLEX: gate_row]
                  { Gap: 1 }
                  [TEXT: gate_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "检票口"
                  [TEXT: gate_value]
                    ATTR: Variant("body"), Weight("bold")
                    CONTENT: "{{order.seat_selection_snapshot.gate|}}"
              [SEPARATOR: train_sep_1]
              [FLEX: train_route_row]
                { Justify: "Between", Align: "Center" }
                [STACK: train_dep]
                  { Gap: 0, Align: "Center" }
                  [TEXT: train_dep_time]
                    ATTR: Variant("h2"), Weight("bold")
                    CONTENT: "{{order.train_offer.departure_time|}}"
                  [TEXT: train_dep_station]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.train_offer.departure_station|}}"
                [STACK: train_mid]
                  { Gap: 0, Align: "Center" }
                  [TEXT: train_no_display]
                    ATTR: Variant("caption"), Weight("bold")
                    CONTENT: "{{order.train_offer.train_no|}}"
                  [ICON: train_arrow]
                    ATTR: Name("arrow-right"), Size("sm")
                  [TEXT: train_duration]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.train_offer.duration|}}"
                [STACK: train_arr]
                  { Gap: 0, Align: "Center" }
                  [TEXT: train_arr_time]
                    ATTR: Variant("h2"), Weight("bold")
                    CONTENT: "{{order.train_offer.arrival_time|}}"
                  [TEXT: train_arr_station]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{order.train_offer.arrival_station|}}"
              [SEPARATOR: train_sep_2]
              [TEXT: stop_stations]
                ATTR: Variant("caption")
                CONTENT: "{{order.train_offer.stop_stations|}}"
      [/IF]

      [IF: is_hotel_order]
        [CARD: hotel_info_card]
          [CARD_HEADER: hotel_info_header]
            [TEXT: hotel_info_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "酒店信息"
          [CARD_CONTENT: hotel_info_content]
            [STACK: hotel_info_stack]
              { Gap: 3 }
              [TEXT: hotel_name]
                ATTR: Variant("h3"), Weight("bold")
                CONTENT: "{{order.hotel_offer.hotel_name|}}"
              [TEXT: hotel_address]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "{{order.hotel_offer.address|}}"
              [SEPARATOR: hotel_sep_1]
              [GRID: hotel_detail_grid]
                { Columns: 2, Gap: 2 }
                [FLEX: room_type_row]
                  { Gap: 1 }
                  [TEXT: room_type_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "房型"
                  [TEXT: room_type_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.room_type_name|}}"
                [FLEX: room_count_row]
                  { Gap: 1 }
                  [TEXT: room_count_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "间数"
                  [TEXT: room_count_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.room_count|}}"
                [FLEX: night_count_row]
                  { Gap: 1 }
                  [TEXT: night_count_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "晚数"
                  [TEXT: night_count_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.night_count|}}"
                [FLEX: bed_type_row]
                  { Gap: 1 }
                  [TEXT: bed_type_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "床型"
                  [TEXT: bed_type_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.bed_type|}}"
                [FLEX: room_area_row]
                  { Gap: 1 }
                  [TEXT: room_area_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "面积"
                  [TEXT: room_area_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.room_area|}}"
                [FLEX: breakfast_row]
                  { Gap: 1 }
                  [TEXT: breakfast_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "早餐"
                  [TEXT: breakfast_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.breakfast_info|}}"
                [FLEX: window_row]
                  { Gap: 1 }
                  [TEXT: window_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "窗型"
                  [TEXT: window_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.window_type|}}"
                [FLEX: floor_row]
                  { Gap: 1 }
                  [TEXT: floor_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "楼层"
                  [TEXT: floor_value]
                    ATTR: Variant("caption")
                    CONTENT: "{{order.hotel_offer.floor_info|}}"
              [SEPARATOR: hotel_sep_2]
              [FLEX: checkin_checkout_row]
                { Justify: "Between" }
                [STACK: checkin_stack]
                  { Gap: 0 }
                  [TEXT: checkin_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "入住日期"
                  [TEXT: checkin_value]
                    CONTENT: "{{order.hotel_offer.check_in_date|}}"
                [STACK: checkout_stack]
                  { Gap: 0 }
                  [TEXT: checkout_label]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "退房日期"
                  [TEXT: checkout_value]
                    CONTENT: "{{order.hotel_offer.check_out_date|}}"
              [SEPARATOR: hotel_sep_3]
              [FLEX: cancel_fee_row]
                { Justify: "Between" }
                [TEXT: cancel_fee_label]
                  ATTR: Variant("caption"), Color("muted")
                  CONTENT: "取消扣费"
                [TEXT: cancel_fee_value]
                  ATTR: Variant("caption")
                  CONTENT: "{{order.hotel_offer.cancellation_fee|}}"
      [/IF]

      [IF: is_flight_order]
        [CARD: flight_passenger_card]
          [CARD_HEADER: flight_passenger_header]
            [TEXT: flight_passenger_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "出行信息"
          [CARD_CONTENT: flight_passenger_content]
            [STACK: flight_passenger_stack]
              { Gap: 2 }
              [FOR: item in order.ticket_passenger_infos]
                [FLEX: passenger_row]
                  { Justify: "Between", Align: "Center" }
                  [FLEX: passenger_name_row]
                    { Gap: 2, Align: "Center" }
                    [TEXT: passenger_name]
                      CONTENT: "{{item.name|}}"
                    [BADGE: ticket_status_badge]
                      ATTR: Variant("outline")
                      CONTENT: "{{item.ticket_status|}}"
                  [TEXT: passenger_id]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.id_number|}}"
              [/FOR]
      [/IF]

      [IF: is_train_order]
        [CARD: train_passenger_card]
          [CARD_HEADER: train_passenger_header]
            [TEXT: train_passenger_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "乘客信息"
          [CARD_CONTENT: train_passenger_content]
            [STACK: train_passenger_stack]
              { Gap: 2 }
              [FOR: item in order.ticket_passenger_infos]
                [FLEX: train_pax_row]
                  { Justify: "Between", Align: "Center" }
                  [FLEX: train_pax_info]
                    { Gap: 2, Align: "Center" }
                    [TEXT: train_pax_name]
                      CONTENT: "{{item.name|}}"
                    [BADGE: seat_no_badge]
                      ATTR: Variant("secondary")
                      CONTENT: "{{item.seat_no|}}"
                    [BADGE: seat_class_badge]
                      ATTR: Variant("outline")
                      CONTENT: "{{item.seat_class|}}"
                  [BADGE: train_ticket_status]
                    ATTR: Variant("outline")
                    CONTENT: "{{item.ticket_status|}}"
              [/FOR]
      [/IF]

      [IF: is_hotel_order]
        [CARD: hotel_guest_card]
          [CARD_HEADER: hotel_guest_header]
            [TEXT: hotel_guest_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "入住人信息"
          [CARD_CONTENT: hotel_guest_content]
            [STACK: hotel_guest_stack]
              { Gap: 2 }
              [FOR: item in order.hotel_offer.guests]
                [FLEX: guest_row]
                  { Justify: "Between", Align: "Center" }
                  [FLEX: guest_info]
                    { Gap: 2, Align: "Center" }
                    [TEXT: guest_room_no]
                      ATTR: Variant("caption"), Color("muted")
                      CONTENT: "{{item.room_no|}}"
                    [TEXT: guest_name]
                      CONTENT: "{{item.name|}}"
                  [TEXT: guest_phone]
                    ATTR: Variant("caption"), Color("muted")
                    CONTENT: "{{item.phone|}}"
              [/FOR]
      [/IF]

      [IF: is_hotel_order]
        [CARD: receipt_card]
          [CARD_HEADER: receipt_header]
            [TEXT: receipt_title]
              ATTR: Variant("h4"), Weight("bold")
              CONTENT: "报销凭证"
          [CARD_CONTENT: receipt_content]
            [STACK: receipt_stack]
              { Gap: 2 }
              [TEXT: receipt_hint]
                ATTR: Variant("caption"), Color("muted")
                CONTENT: "如需报销凭证，请在退房后申请"
              [IF: order_status_completed]
                [BUTTON: receipt_btn]
                  ATTR: Variant("outline")
                  CONTENT: "申请报销凭证"
              [/IF]
      [/IF]

  [SECTION: action_bar]
    [FLEX: action_row]
      { Gap: 2 }
      [IF: is_flight_order]
        [BUTTON: refund_flight_btn]
          ATTR: Variant("outline")
          CONTENT: "申请退票"
        [BUTTON: change_flight_btn]
          ATTR: Variant("outline")
          CONTENT: "申请改签"
      [/IF]
      [IF: is_train_order]
        [BUTTON: change_train_btn]
          ATTR: Variant("outline")
          CONTENT: "改签"
        [BUTTON: refund_train_btn]
          ATTR: Variant("outline")
          CONTENT: "退票"
      [/IF]
      [IF: order_pending]
        [BUTTON: cancel_order_btn]
          ATTR: Variant("destructive")
          CONTENT: "取消订单"
      [/IF]
      [BUTTON: contact_service_btn]
        ATTR: Variant("secondary")
        CONTENT: "联系客服"
