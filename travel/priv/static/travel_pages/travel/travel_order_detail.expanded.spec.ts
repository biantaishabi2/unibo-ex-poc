import { test, expect } from '@playwright/test';

const __DATA_CONTRACT = {
  "binds": [
    {
      "name": "route_record_id",
      "path": "id",
      "source": "route"
    },
    {
      "name": "created_display_value",
      "path": "host_member_id",
      "source": "form"
    }
  ],
  "cleanup": [
    {
      "api": "destroy",
      "ignore_missing": true,
      "path": "id",
      "source": "created_record_id"
    }
  ],
  "inputs": [
    "route",
    "form",
    "generated_form_values"
  ],
  "setup": [
    {
      "binds": [
        {
          "name": "hotel_offer_id",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "never",
      "create_blockers": [
        "actor_required"
      ],
      "depends_on": [],
      "domain": "Travel",
      "entity": "HotelOffer",
      "freshness": "match_only",
      "graphql_field": "listTravelHotelOffers",
      "kind": "related_list_first",
      "name": "resolve_hotel_offer_id",
      "owner": "dependent"
    },
    {
      "binds": [
        {
          "name": "seed_record_id",
          "path": "id",
          "source": "result"
        },
        {
          "name": "active_record_id",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "never",
      "create_blockers": [
        "actor_required"
      ],
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "match_only",
      "graphql_field": "listTravelTravelOrders",
      "index": 0,
      "kind": "entity_list_first",
      "name": "resolve_current_record",
      "owner": "root",
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_confirm_quote",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_confirm_quote_0",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_confirm_quote_0",
        "currency": "E2E_{{__run_id}}_currency_state_confirm_quote_0",
        "customer_id": "2b473943-5c2b-42f8-94d6-e3ddd3cee4cc",
        "host_shop_id": "2f3a3a35-564d-453b-84d2-d7cee1ced8e2",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_confirm_quote_0",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_confirm_quote_0\"}",
        "tenant_id": "37544d27-47fa-4ed7-94dc-c7d7e6ccc8d5",
        "ticket_passenger_infos": "{\"variant\":\"state_confirm_quote_0\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_confirm_quote",
      "owner": "root",
      "prepare_actions": [],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_submit_order",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_submit_order_0",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_submit_order_0",
        "currency": "E2E_{{__run_id}}_currency_state_submit_order_0",
        "customer_id": "3b482839-5a25-43c8-94e6-e9d1dacee6be",
        "host_shop_id": "214a3b24-4c4b-4f0c-94d2-e7d4d5d5d8e4",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_submit_order_0",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_submit_order_0\"}",
        "tenant_id": "264a4b21-18ca-4ee7-9ad0-ced7e8bed8d6",
        "ticket_passenger_infos": "{\"variant\":\"state_submit_order_0\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_submit_order",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_submit_waitlist",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_submit_waitlist_1",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_submit_waitlist_1",
        "currency": "E2E_{{__run_id}}_currency_state_submit_waitlist_1",
        "customer_id": "43372d48-542f-463c-b317-e9d1dacee6be",
        "host_shop_id": "21522a29-5b45-494f-8831-18d4d5d5d8e4",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_submit_waitlist_1",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_submit_waitlist_1\"}",
        "tenant_id": "2b59452b-5b3e-4d18-9ad0-ced7e8bee0c5",
        "ticket_passenger_infos": "{\"variant\":\"state_submit_waitlist_1\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 1,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_submit_waitlist",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_mark_payment_succeeded",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_mark_payment_succeeded_0",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_mark_payment_succeeded_0",
        "currency": "E2E_{{__run_id}}_currency_state_mark_payment_succeeded_0",
        "customer_id": "75432942-5c25-463d-b743-3a463c29461f",
        "host_shop_id": "82843625-554d-4f4f-8935-44254a373344",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_mark_payment_succeeded_0",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_mark_payment_succeeded_0\"}",
        "tenant_id": "27534d21-5b3f-4144-ab45-3032481f12d1",
        "ticket_passenger_infos": "{\"variant\":\"state_mark_payment_succeeded_0\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_mark_payment_succeeded",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_mark_order_failed",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_mark_order_failed_1",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_mark_order_failed_1",
        "currency": "E2E_{{__run_id}}_currency_state_mark_order_failed_1",
        "customer_id": "303b3633-4e27-4c34-b944-3412d8c4e1d1",
        "host_shop_id": "343f2e32-463f-4145-8037-451f16d3cedf",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_mark_order_failed_1",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_mark_order_failed_1\"}",
        "tenant_id": "34443f23-5136-4345-a511-cccde3d1cdc9",
        "ticket_passenger_infos": "{\"variant\":\"state_mark_order_failed_1\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 1,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_mark_order_failed",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_mark_booked",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_mark_booked_0",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_mark_booked_0",
        "currency": "E2E_{{__run_id}}_currency_state_mark_booked_0",
        "customer_id": "3b412938-47f6-43c8-94e0-d5e1d8c4d4ce",
        "host_shop_id": "314a3425-4b38-40dc-94d2-e1c0e5d3ced2",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_mark_booked_0",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_mark_booked_0\"}",
        "tenant_id": "274938f2-e8ca-4ee1-86e0-cccdd6ced8cf",
        "ticket_passenger_infos": "{\"variant\":\"state_mark_booked_0\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_mark_booked",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order",
        "mark_payment_succeeded"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_fulfill_waitlist",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_fulfill_waitlist_1",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_fulfill_waitlist_1",
        "currency": "E2E_{{__run_id}}_currency_state_fulfill_waitlist_1",
        "customer_id": "2b4d253d-5c32-4c3b-8838-1adbd3cedecb",
        "host_shop_id": "2e3a4021-504d-4c45-8746-3905dfced8dc",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_fulfill_waitlist_1",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_fulfill_waitlist_1\"}",
        "tenant_id": "234e4d2e-513d-4239-8bda-c7d7e0cbc8db",
        "ticket_passenger_infos": "{\"variant\":\"state_fulfill_waitlist_1\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 1,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_fulfill_waitlist",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order",
        "mark_payment_succeeded"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_cancel_waitlist",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_cancel_waitlist_2",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_cancel_waitlist_2",
        "currency": "E2E_{{__run_id}}_currency_state_cancel_waitlist_2",
        "customer_id": "43372d48-542f-463c-b308-d5ddd0cadebe",
        "host_shop_id": "21522a29-5b45-494f-8831-09c0e1cbd4dc",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_cancel_waitlist_2",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_cancel_waitlist_2\"}",
        "tenant_id": "2b59452b-5b3e-4d09-86dc-c4d3e0bee0c5",
        "ticket_passenger_infos": "{\"variant\":\"state_cancel_waitlist_2\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 2,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_cancel_waitlist",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order",
        "mark_payment_succeeded"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_mark_completed",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_mark_completed_0",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_mark_completed_0",
        "currency": "E2E_{{__run_id}}_currency_state_mark_completed_0",
        "customer_id": "39463039-5c2b-4727-84e0-d5e1d8c4d5ce",
        "host_shop_id": "3148392c-4c4d-4540-b302-e1c0e5d3ced3",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_mark_completed_0",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_mark_completed_0\"}",
        "tenant_id": "2e4a4d27-4c29-4ee1-86e0-cccdd7ced6d4",
        "ticket_passenger_infos": "{\"variant\":\"state_mark_completed_0\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_mark_completed",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order",
        "mark_payment_succeeded",
        "mark_booked"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_request_cancel",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_request_cancel_1",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_request_cancel_1",
        "currency": "E2E_{{__run_id}}_currency_state_request_cancel_1",
        "customer_id": "2b392542-4b2b-4f27-85e5-d9e0e2cae5d3",
        "host_shop_id": "363a2c21-553c-4548-b303-e6c4e4ddd4e3",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_request_cancel_1",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_request_cancel_1\"}",
        "tenant_id": "23533c27-5429-4fe6-8adf-d6d3e7d3c8c7",
        "ticket_passenger_infos": "{\"variant\":\"state_request_cancel_1\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 1,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_request_cancel",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order",
        "mark_payment_succeeded",
        "mark_booked"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_execute_cancel",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_execute_cancel_0",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_execute_cancel_0",
        "currency": "E2E_{{__run_id}}_currency_state_execute_cancel_0",
        "customer_id": "2b392542-4b2b-4f27-84d8-ecd4d0dae6c4",
        "host_shop_id": "273a2c21-553c-4548-b302-d9d7d8cbe4e4",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_execute_cancel_0",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_execute_cancel_0\"}",
        "tenant_id": "23533c27-5429-4ed9-9dd3-c4e3e8c4c8c7",
        "ticket_passenger_infos": "{\"variant\":\"state_execute_cancel_0\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 0,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_execute_cancel",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order",
        "mark_payment_succeeded",
        "mark_booked",
        "request_cancel"
      ],
      "where_equals": "draft",
      "where_path": "status"
    },
    {
      "binds": [
        {
          "name": "state_action_record_id_cancel_cancel_request",
          "path": "id",
          "source": "result"
        }
      ],
      "cleanup_policy": "always",
      "create_blockers": [],
      "create_graphql_field": "createTravelTravelOrder",
      "create_input": {
        "contact_name": "E2E_{{__run_id}}_contact_name_state_cancel_cancel_request_1",
        "contact_phone": "E2E_{{__run_id}}_contact_phone_state_cancel_cancel_request_1",
        "currency": "E2E_{{__run_id}}_currency_state_cancel_cancel_request_1",
        "customer_id": "2f373237-4d32-423a-b947-4a42433e3def",
        "host_shop_id": "523e2a2e-4a3e-4c3b-8637-4835463e483b",
        "hotel_offer_id": "{{hotel_offer_id}}",
        "order_no": "E2E_{{__run_id}}_order_no_state_cancel_cancel_request_1",
        "points_deduction_amount": 1,
        "points_to_use": 1,
        "product_type": "hotel",
        "seat_selection_snapshot": "{\"variant\":\"state_cancel_cancel_request_1\"}",
        "tenant_id": "30483e2e-473c-4348-bb41-37473fefccc5",
        "ticket_passenger_infos": "{\"variant\":\"state_cancel_cancel_request_1\"}",
        "total_amount": 1,
        "traveler_count": 1
      },
      "depends_on": [],
      "domain": "Travel",
      "entity": "TravelOrder",
      "freshness": "prefer_create",
      "graphql_field": "listTravelTravelOrders",
      "index": 1,
      "kind": "entity_list_match_or_create",
      "match_keys": [
        {
          "equals": "{{hotel_offer_id}}",
          "path": "hotel_offer_id"
        }
      ],
      "name": "resolve_state_action_record_cancel_cancel_request",
      "owner": "root",
      "prepare_actions": [
        "confirm_quote",
        "submit_order",
        "mark_payment_succeeded",
        "mark_booked",
        "request_cancel"
      ],
      "where_equals": "draft",
      "where_path": "status"
    }
  ]
};
const __WAIT_CONTRACT = {
  "action": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_cancel_cancel_request": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_cancel_waitlist": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_confirm_change": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_confirm_quote": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_execute_cancel": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_fulfill_waitlist": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_mark_booked": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_mark_completed": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_mark_order_failed": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_mark_payment_succeeded": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_request_cancel": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_request_change": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_submit_order": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "action_submit_waitlist": {
    "mode": "reload_message",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "destroy": {
    "mode": "url_and_root",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_list"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "url_contains",
      "selector": "#travel_order_list",
      "state_key": null,
      "url_contains": "/pages/travel/travel_order"
    },
    "url_contains": "/pages/travel/travel_order"
  },
  "form_submit": {
    "mode": "form_settled",
    "reload_messages": [
      "page_host_reload"
    ],
    "selectors": [
      "#travel_order_edit_form, #main_form, form[phx-submit=\"form_submit\"]",
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 8000,
    "until": {
      "kind": "form_settled",
      "selector": "#travel_order_edit_form, #main_form, form[phx-submit=\"form_submit\"]",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "load": {
    "mode": "dom_visible",
    "reload_messages": [],
    "selectors": [
      "#travel_order_detail"
    ],
    "state_keys": [],
    "timeout": 5000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_detail",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  },
  "toggle_edit": {
    "mode": "dom_visible",
    "reload_messages": [],
    "selectors": [
      "#travel_order_edit_form, #main_form, form[phx-submit=\"form_submit\"]"
    ],
    "state_keys": [],
    "timeout": 3000,
    "until": {
      "kind": "visible",
      "selector": "#travel_order_edit_form, #main_form, form[phx-submit=\"form_submit\"]",
      "state_key": null,
      "url_contains": null
    },
    "url_contains": null
  }
};
const __VERIFICATION_CONTRACT = {
  "action_cancel_cancel_request": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "booked",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "cancel_cancel_request",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "booked"
      }
    ]
  },
  "action_cancel_waitlist": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "cancelled",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "cancel_waitlist",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "cancelled"
      }
    ]
  },
  "action_confirm_quote": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "quoted",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "confirm_quote",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "quoted"
      }
    ]
  },
  "action_execute_cancel": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "cancelled",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "execute_cancel",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "cancelled"
      }
    ]
  },
  "action_fulfill_waitlist": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "booked",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "fulfill_waitlist",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "booked"
      }
    ]
  },
  "action_mark_booked": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "booked",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "mark_booked",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "booked"
      }
    ]
  },
  "action_mark_completed": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "completed",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "mark_completed",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "completed"
      }
    ]
  },
  "action_mark_order_failed": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "failed",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "mark_order_failed",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "failed"
      }
    ]
  },
  "action_mark_payment_succeeded": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "booking_pending",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "mark_payment_succeeded",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "booking_pending"
      }
    ]
  },
  "action_request_cancel": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "cancel_pending",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "request_cancel",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "cancel_pending"
      }
    ]
  },
  "action_submit_order": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "submitted",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "submit_order",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "submitted"
      }
    ]
  },
  "action_submit_waitlist": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "submitted",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "status",
      "source": "active_record_id"
    },
    "event": "submit_waitlist",
    "ui": [
      {
        "assert": "text_contains",
        "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
        "value": "submitted"
      }
    ]
  },
  "create": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "created_record_id"
        }
      ],
      "binds": [
        {
          "name": "active_record_id",
          "path": "id",
          "source": "backend_result"
        },
        {
          "name": "created_record_id",
          "path": "id",
          "source": "backend_result"
        }
      ],
      "equals": "$form.order_no",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "field_equals",
      "path": "order_no",
      "source": "created_record_id"
    },
    "ui": [
      {
        "assert": "visible",
        "selector": "#travel_order_detail",
        "value": null
      }
    ]
  },
  "destroy": {
    "backend": {
      "api": "list",
      "args": [],
      "binds": [],
      "equals": null,
      "excludes_source": "active_record_id",
      "graphql_field": "listTravelTravelOrders",
      "op": "not_contains",
      "path": "results[].id",
      "source": "active_record_id"
    },
    "ui": [
      {
        "assert": "url_contains",
        "selector": null,
        "value": "/pages/travel/travel_order"
      },
      {
        "assert": "visible",
        "selector": "#travel_order_list",
        "value": null
      }
    ]
  },
  "load": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [
        {
          "name": "active_record_id",
          "path": "id",
          "source": "backend_result"
        }
      ],
      "equals": null,
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "exists",
      "path": "id",
      "source": "active_record_id"
    },
    "ui": [
      {
        "assert": "visible",
        "selector": "#travel_order_detail",
        "value": null
      }
    ]
  },
  "state_transitions": [
    {
      "backend": {
        "api": "get",
        "args": [
          {
            "name": "id",
            "source": "active_record_id"
          }
        ],
        "binds": [],
        "equals": "quoted",
        "excludes_source": null,
        "graphql_field": "getTravelTravelOrder",
        "op": "equals",
        "path": "status",
        "source": "active_record_id"
      },
      "event": "confirm_quote",
      "ui": [
        {
          "assert": "text_contains",
          "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
          "value": "quoted"
        }
      ]
    },
    {
      "backend": {
        "api": "get",
        "args": [
          {
            "name": "id",
            "source": "active_record_id"
          }
        ],
        "binds": [],
        "equals": "submitted",
        "excludes_source": null,
        "graphql_field": "getTravelTravelOrder",
        "op": "equals",
        "path": "status",
        "source": "active_record_id"
      },
      "event": "submit_order",
      "ui": [
        {
          "assert": "text_contains",
          "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
          "value": "submitted"
        }
      ]
    },
    {
      "backend": {
        "api": "get",
        "args": [
          {
            "name": "id",
            "source": "active_record_id"
          }
        ],
        "binds": [],
        "equals": "booking_pending",
        "excludes_source": null,
        "graphql_field": "getTravelTravelOrder",
        "op": "equals",
        "path": "status",
        "source": "active_record_id"
      },
      "event": "mark_payment_succeeded",
      "ui": [
        {
          "assert": "text_contains",
          "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
          "value": "booking_pending"
        }
      ]
    },
    {
      "backend": {
        "api": "get",
        "args": [
          {
            "name": "id",
            "source": "active_record_id"
          }
        ],
        "binds": [],
        "equals": "booked",
        "excludes_source": null,
        "graphql_field": "getTravelTravelOrder",
        "op": "equals",
        "path": "status",
        "source": "active_record_id"
      },
      "event": "mark_booked",
      "ui": [
        {
          "assert": "text_contains",
          "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
          "value": "booked"
        }
      ]
    },
    {
      "backend": {
        "api": "get",
        "args": [
          {
            "name": "id",
            "source": "active_record_id"
          }
        ],
        "binds": [],
        "equals": "completed",
        "excludes_source": null,
        "graphql_field": "getTravelTravelOrder",
        "op": "equals",
        "path": "status",
        "source": "active_record_id"
      },
      "event": "mark_completed",
      "ui": [
        {
          "assert": "text_contains",
          "selector": "#travel_order_status_badge, #travel_order_fcl_status_badge, #state_badge",
          "value": "completed"
        }
      ]
    }
  ],
  "toggle_edit": {
    "backend": null,
    "ui": [
      {
        "assert": "visible",
        "selector": "#travel_order_detail",
        "value": null
      }
    ]
  },
  "update": {
    "backend": {
      "api": "get",
      "args": [
        {
          "name": "id",
          "source": "active_record_id"
        }
      ],
      "binds": [],
      "equals": "$form.ticket_passenger_infos",
      "excludes_source": null,
      "graphql_field": "getTravelTravelOrder",
      "op": "equals",
      "path": "ticket_passenger_infos",
      "source": "active_record_id"
    },
    "ui": [
      {
        "assert": "visible",
        "selector": "#travel_order_detail",
        "value": null
      }
    ]
  }
};
const __BACKEND_API_MAP = {
  "list": "Travel.TravelOrder.list",
  "get": "Travel.TravelOrder.get",
  "create": "Travel.TravelOrder.create",
  "update": "Travel.TravelOrder.update",
  "destroy": "Travel.TravelOrder.destroy"
};
const __BACKEND_SELECTION = "id tenant_id: tenantId host_shop_id: hostShopId host_member_id: hostMemberId host_enterprise_id: hostEnterpriseId order_no: orderNo product_type: productType booking_mode: bookingMode contact_name: contactName contact_phone: contactPhone traveler_count: travelerCount total_amount: totalAmount points_to_use: pointsToUse points_deduction_amount: pointsDeductionAmount recommended_payment_method: recommendedPaymentMethod currency status change_status: changeStatus waitlist_status: waitlistStatus original_order_ref: originalOrderRef ticket_passenger_infos: ticketPassengerInfos seat_selection_snapshot: seatSelectionSnapshot supplier_order_ref: supplierOrderRef payment_external_ref: paymentExternalRef inserted_at: insertedAt updated_at: updatedAt";
const __BASE_URL = "http://localhost:4100/";
const __GRAPHQL_URL = new URL("/api/graphql", __BASE_URL).toString();

function locatorFor(page, selector) {
  const loc = page.locator(selector);
  return selector.includes(',') ? loc.first() : loc;
}

function readValueAtPath(value, path) {
  if (!path) return value;
  return String(path).split('.').reduce((acc, part) => {
    if (acc == null) return undefined;
    if (part === '[]') return Array.isArray(acc) ? acc : undefined;
    if (/^\d+$/.test(part)) return Array.isArray(acc) ? acc[Number(part)] : undefined;
    if (part.endsWith('[]')) {
      const key = part.slice(0, -2);
      const next = acc?.[key];
      return Array.isArray(next) ? next : undefined;
    }
    return acc?.[part];
  }, value);
}

function readContextValue(ctx, source) {
  if (!source) return undefined;
  const parts = String(source).split('.');
  const root = parts.shift();
  const base = root && Object.prototype.hasOwnProperty.call(ctx, root) ? ctx[root] : ctx?.[source];
  if (parts.length === 0) return base;
  return readValueAtPath(base, parts.join('.'));
}

function resolveCleanupSourceValue(ctx, source, path) {
  const base = readContextValue(ctx, source);
  if (base == null) return undefined;
  if (!path || typeof base !== 'object') return base;
  const nested = readValueAtPath(base, path);
  return nested == null ? base : nested;
}

function assignContextValue(ctx, name, value) {
  if (!name) return;
  const parts = String(name).split('.').filter(Boolean);
  if (parts.length === 0) return;
  let cursor = ctx;
  while (parts.length > 1) {
    const key = parts.shift();
    if (!key) return;
    const next = cursor[key];
    if (!next || typeof next !== 'object') cursor[key] = {};
    cursor = cursor[key];
  }
  cursor[parts[0]] = value;
}

function resolveStateActionTemplateValue(ctx, key) {
  const name = String(key || '').trim();
  if (!name.startsWith('state_action_record_id_')) return undefined;
  return defaultRecordId(ctx);
}

function resolveTemplateString(ctx, raw) {
  if (typeof raw !== 'string' || raw === '') return raw;
  let out = raw.replace(/\{\{\s*([^}]+?)\s*\}\}/g, (_m, key) => {
    const normalizedKey = key.trim();
    const v = readContextValue(ctx, normalizedKey);
    if (v != null) return String(v);
    const fallback = resolveStateActionTemplateValue(ctx, normalizedKey);
    return fallback == null ? '' : String(fallback);
  });
  out = out.replace(/\$([a-zA-Z0-9_.]+)/g, (_m, key) => {
    const v = readContextValue(ctx, key);
    return v == null ? '' : String(v);
  });
  return out;
}

function escapeRegex(value) {
  return String(value || '').replace(/[.*+?^$()|[\]\\]/g, '\\$&');
}

function pascalize(value) {
  return String(value || '')
    .split(/[^a-zA-Z0-9]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('');
}

function snakeize(value) {
  return String(value || '')
    .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
    .replace(/[^a-zA-Z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .toLowerCase();
}

function pluralize(value) {
  const s = String(value || '');
  return s + 's';
}

function tenantIdFromValue(value) {
  if (typeof value === 'string' || typeof value === 'number') {
    return String(value || '').trim();
  }
  if (value && typeof value === 'object') {
    const direct = value.tenant_id ?? value.tenantId;
    return direct == null ? '' : String(direct).trim();
  }
  return '';
}

function rememberTenantContext(ctx, value) {
  const tenantId = tenantIdFromValue(value);
  if (tenantId) ctx.tenant_id = tenantId;
}

function graphqlHeaders(ctx, extraHeaders) {
  const headers = { 'content-type': 'application/json', ...(extraHeaders || {}) };
  const tenantId = tenantIdFromValue(ctx?.tenant_id) || tenantIdFromValue(ctx?.tenant);
  if (tenantId && !headers['x-tenant-id'] && !headers['X-Tenant-Id']) {
    headers['x-tenant-id'] = tenantId;
  }
  return headers;
}

async function graphqlRequest(ctx, query, variables, extraHeaders) {
  let response;
  try {
    response = await fetch(__GRAPHQL_URL, {
      method: 'POST',
      headers: graphqlHeaders(ctx, extraHeaders),
      body: JSON.stringify({ query, variables }),
    });
  } catch (e) {
    throw new Error('GraphQL request to ' + __GRAPHQL_URL + ' failed: ' + e.message);
  }
  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new Error('GraphQL ' + __GRAPHQL_URL + ' returned ' + response.status + ': ' + text.slice(0, 200));
  }
  return await response.json();
}

async function loadGraphqlSchemaCache(ctx) {
  if (ctx.__graphqlSchema) return ctx.__graphqlSchema;
  const payload = await graphqlRequest(ctx, '{ __schema { queryType { fields { name } } mutationType { fields { name } } } }', {});
  const queryFields = (payload?.data?.__schema?.queryType?.fields || []).map((field) => field.name);
  const mutationFields = (payload?.data?.__schema?.mutationType?.fields || []).map((field) => field.name);
  if (queryFields.length === 0 && mutationFields.length === 0) {
    throw new Error('GraphQL introspection at ' + __GRAPHQL_URL + ' returned no fields. Is the server running? Response: ' + JSON.stringify(payload).slice(0, 300));
  }
  ctx.__graphqlSchema = { query: queryFields, mutation: mutationFields };
  return ctx.__graphqlSchema;
}

async function resolveContractGraphqlField(ctx, mode, explicitField, domain, entity, actionName) {
  const schema = await loadGraphqlSchemaCache(ctx);
  const fields = mode === 'query' ? schema.query : schema.mutation;
  const explicit = String(explicitField || '').trim();
  if (explicit && fields.includes(explicit)) return explicit;
  if (explicit) {
    const camel = pascalize(explicit).replace(/^./, (ch) => ch.toLowerCase());
    if (camel !== explicit && fields.includes(camel)) return camel;
  }
  return await resolveGraphqlField(ctx, mode, domain, entity, actionName);
}

async function resolveGraphqlField(ctx, mode, domain, entity, actionName) {
  const schema = await loadGraphqlSchemaCache(ctx);
  const fields = mode === 'query' ? schema.query : schema.mutation;
  const domainName = pascalize(domain);
  const entityName = pascalize(entity);
  const domainSnake = snakeize(domain);
  const entitySnake = snakeize(entity);
  const candidates = [];
  let normalizedPrefix = (domainName + entityName).replace(/^./, (ch) => ch.toLowerCase());
  if (mode === 'query') {
    if (actionName === 'list') {
      normalizedPrefix = 'list' + domainName + entityName;
      candidates.push('list_' + domainSnake + '_' + pluralize(entitySnake));
    } else if (actionName === 'get') {
      normalizedPrefix = 'get' + domainName + entityName;
      candidates.push('get_' + domainSnake + '_' + entitySnake);
    }
  } else if (actionName === 'destroy') {
    normalizedPrefix = 'delete' + domainName + entityName;
    candidates.push('delete_' + domainSnake + '_' + entitySnake);
  } else if (actionName) {
    const actionPrefix = pascalize(actionName);
    normalizedPrefix = actionPrefix.charAt(0).toLowerCase() + actionPrefix.slice(1) + domainName + entityName;
    candidates.push(snakeize(actionName) + '_' + domainSnake + '_' + entitySnake);
  }
  candidates.push(normalizedPrefix);
  return candidates.find((candidate) => fields.includes(candidate)) || fields.find((field) => candidates.some((candidate) => field === candidate || (field.startsWith(candidate) && /^(s|es|_|$)/.test(field.slice(candidate.length))))) || null;
}

function applyBindings(ctx, binds, resultValue) {
  for (const bind of Array.isArray(binds) ? binds : []) {
    const source = typeof bind?.source === 'string' ? bind.source : 'result';
    const base = source === 'result' || source === 'backend_result'
      ? resultValue
      : readContextValue(ctx, source);
    const value = readValueAtPath(base, bind?.path || null);
    assignContextValue(ctx, bind?.name, value);
  }
}

function refreshDataBindings(ctx) {
  applyBindings(ctx, __DATA_CONTRACT.binds, null);
}

function resolveTemplateDeep(ctx, value) {
  if (typeof value === 'string') return resolveTemplateString(ctx, value);
  if (Array.isArray(value)) return value.map((item) => resolveTemplateDeep(ctx, item));
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([key, item]) => [key, resolveTemplateDeep(ctx, item)]));
  }
  return value;
}

function toGraphqlLiteral(value) {
  if (value == null) return 'null';
  if (Array.isArray(value)) return '[' + value.map((item) => toGraphqlLiteral(item)).join(', ') + ']';
  if (typeof value === 'object') {
    return '{ ' + Object.entries(value).map(([key, item]) => `${key}: ${toGraphqlLiteral(item)}`).join(', ') + ' }';
  }
  if (typeof value === 'string') return JSON.stringify(value);
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  return JSON.stringify(String(value));
}

function defaultRecordId(ctx) {
  return ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.created_record_id || ctx.route?.id || '';
}

function resolveBackendAssertionId(ctx, assertion) {
  const idArg = (Array.isArray(assertion?.args) ? assertion.args : []).find((arg) => arg?.name === 'id');
  const explicit = resolveTemplateString(ctx, idArg?.source ? '{{' + idArg.source + '}}' : '{{route.id}}');
  return explicit || defaultRecordId(ctx);
}

async function runSetupAction(ctx, item, recordId, actionName) {
  const field = await resolveContractGraphqlField(ctx, 'mutation', null, item.domain, item.entity, actionName);
  if (!field) throw new Error('missing GraphQL action field for setup ' + JSON.stringify({ item, actionName }));
  const payload = await graphqlRequest(ctx, `mutation ContractSetupAction($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: recordId });
  const errors = payload?.errors || payload?.data?.[field]?.errors || [];
  if (Array.isArray(errors) && errors.length > 0) {
    throw new Error('setup action failed for ' + String(actionName));
  }
  return payload?.data?.[field]?.result || null;
}

async function runSetupItem(page, ctx, item) {
  if (!item) return;
  if (item.kind === 'related_list_first' || item.kind === 'entity_list_first' || item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create') {
    const savedTenantId = ctx.tenant_id;
    const inputValue = resolveTemplateDeep(ctx, item.create_input || {});
    const field = await resolveContractGraphqlField(ctx, 'query', item.graphql_field, item.domain, item.entity, 'list');
    if (!field) throw new Error('missing GraphQL list field for setup ' + JSON.stringify(item));
    const wherePath = typeof item.where_path === 'string' ? item.where_path.trim() : '';
    const whereField = /^[A-Za-z_][A-Za-z0-9_]*$/.test(wherePath) ? wherePath : '';
    const selectionFields = Array.from(new Set(['id', ...(whereField ? [whereField] : [])])).join(' ');
    const payload = await graphqlRequest(ctx, `query ContractSetup { ${field} { results { ${selectionFields} } count } }`, {});
    const rows = Array.isArray(payload?.data?.[field]?.results) ? payload.data[field].results : [];
    rememberTenantContext(ctx, inputValue);
    const whereEquals = typeof item.where_equals === 'string' ? resolveTemplateString(ctx, item.where_equals) : '';
    const matched = whereField
      ? rows.filter((row) => String(readValueAtPath(row, whereField) ?? '') === whereEquals)
      : rows;
    const rawIndex = Number.isInteger(item.index) ? Number(item.index) : Number(item.index || 0);
    const index = Number.isFinite(rawIndex) && rawIndex >= 0 ? rawIndex : 0;
    let result = matched[index] || matched[0];
    const prepareActions = Array.isArray(item.prepare_actions) ? item.prepare_actions : [];
    if (!result && (item.kind === 'entity_list_first_or_create' || item.kind === 'entity_list_match_or_create')) {
      const createField = await resolveContractGraphqlField(ctx, 'mutation', item.create_graphql_field, item.domain, item.entity, 'create');
      if (!createField) throw new Error('missing GraphQL create field for setup ' + JSON.stringify(item));
      const createPayload = await graphqlRequest(ctx, `mutation ContractSetupCreate { ${createField}(input: ${toGraphqlLiteral(inputValue)}) { result { id } errors { message } } }`, {});
      const errors = createPayload?.errors || createPayload?.data?.[createField]?.errors || [];
      if (Array.isArray(errors) && errors.length > 0) {
        throw new Error('setup create failed for ' + String(item.name || createField) + ': ' + JSON.stringify(errors));
      }
      result = createPayload?.data?.[createField]?.result || null;
      if (result?.id) {
        ctx.__cleanup_queue = ctx.__cleanup_queue || [];
        ctx.__cleanup_queue.push({ id: result.id, domain: item.domain, entity: item.entity });
      }
    }
    if (item.cleanup_policy === 'never') { for (const row of rows) { if (row?.id) ctx.__seed_ids.add(row.id); } }
    if (!result) throw new Error('setup returned no rows for ' + String(item.name || field));
    for (const actionName of prepareActions) {
      if (!result?.id) break;
      result = await runSetupAction(ctx, item, result.id, String(actionName || '').trim()) || result;
    }
    applyBindings(ctx, item.binds, result);
    refreshDataBindings(ctx);
    ctx.tenant_id = savedTenantId;
  }
}

async function ensureContractSetup(page, ctx) {
  if (ctx.__setupDone) return;
  for (const item of Array.isArray(__DATA_CONTRACT.setup) ? __DATA_CONTRACT.setup : []) {
    await runSetupItem(page, ctx, item);
  }
  ctx.__setupDone = true;
}

function parseApiRef(apiRef) {
  const parts = String(apiRef || '').split('.');
  if (parts.length < 3) return null;
  return { domain: parts[0], entity: parts[1], action: parts[2] };
}

function collectVerificationEntries(verificationKey, caseKind, covers) {
  const entries = [];
  const pushEntry = (entry) => {
    if (!entry) return;
    if (!entries.includes(entry)) entries.push(entry);
  };
  if (verificationKey && verificationKey !== '__AUTO__') {
    pushEntry(__VERIFICATION_CONTRACT[verificationKey]);
  } else {
    if (caseKind === 'load') pushEntry(__VERIFICATION_CONTRACT.load);
    for (const cover of Array.isArray(covers) ? covers : []) {
      pushEntry(__VERIFICATION_CONTRACT[cover]);
    }
  }
  for (const cover of Array.isArray(covers) ? covers : []) {
    if (!String(cover).startsWith('action_')) continue;
    const event = String(cover).slice('action_'.length);
    const matches = Array.isArray(__VERIFICATION_CONTRACT.state_transitions) ? __VERIFICATION_CONTRACT.state_transitions.filter((item) => item?.event === event) : [];
    for (const match of matches) pushEntry(match);
  }
  return entries;
}

async function runWaitEntry(page, ctx, entry) {
  if (!entry) return;
  const timeout = Number(entry?.timeout) > 0 ? Number(entry.timeout) : 15000;
  await waitForLiveViewReady(page, timeout);
  const until = entry?.until || {};
  const kind = String(until?.kind || entry?.mode || '').trim();
  const selector = typeof until?.selector === 'string' ? until.selector : (Array.isArray(entry?.selectors) ? entry.selectors[0] : null);
  const urlContains = typeof until?.url_contains === 'string' ? until.url_contains : entry?.url_contains;
  if ((kind === 'visible' || kind === 'dom_visible' || kind === 'state_key') && selector) {
    await expect(locatorFor(page, selector)).toBeVisible({ timeout });
  }
  if ((kind === 'hidden' || kind === 'dom_hidden') && selector) {
    await expect(locatorFor(page, selector)).toBeHidden({ timeout });
  }
  if (kind === 'form_settled' && selector) {
    const formLocator = locatorFor(page, selector);
    const fallbackSelectors = Array.isArray(entry?.selectors) ? entry.selectors.filter((item) => item && item !== selector) : [];
    try {
      await formLocator.waitFor({ state: 'hidden', timeout });
    } catch (error) {
      let settled = false;
      for (const candidate of fallbackSelectors) {
        try {
          await expect(locatorFor(page, candidate)).toBeVisible({ timeout: Math.max(1000, Math.floor(timeout / 2)) });
          settled = true;
          break;
        } catch (_candidateError) {}
      }
      const stillVisible = await formLocator.isVisible().catch(() => false);
      if (stillVisible && !settled) throw error;
    }
    await syncRouteContext(page, ctx);
  }
  if (kind === 'url_contains' || kind === 'url_and_root') {
    const expectedUrl = resolveTemplateString(ctx, String(urlContains || ''));
    if (expectedUrl) {
      try {
        await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout });
      } catch (_e) {
        await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout });
      }
    }
    if (selector) await expect(locatorFor(page, selector)).toBeVisible({ timeout });
    await syncRouteContext(page, ctx);
  }
}

async function retryBackendAssertion(timeout, task) {
  const deadline = Date.now() + timeout;
  let lastError = null;
  while (Date.now() <= deadline) {
    try {
      return await task();
    } catch (error) {
      lastError = error;
      await new Promise((resolve) => setTimeout(resolve, 200));
    }
  }
  throw lastError || new Error('backend assertion timed out');
}

async function snapshotPreCreateIds(ctx) {
  if (ctx.__pre_create_ids) return;
  const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  if (!listApiRef) return;
  try {
    const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
    if (!listField) return;
    const payload = await graphqlRequest(ctx, `query CaptureBaseline { ${listField} { results { id } count } }`, {});
    const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
    ctx.__pre_create_ids = new Set(rows.map((r) => r?.id).filter(Boolean));
  } catch (e) { if (e && e.message) console.error('snapshotPreCreateIds failed:', e.message); }
}

async function runCaseWait(page, ctx, waitKey, covers) {
  const entries = [];
  const pushEntry = (entry) => {
    if (!entry) return;
    if (!entries.includes(entry)) entries.push(entry);
  };
  if (waitKey && waitKey !== '__AUTO__') {
    pushEntry(__WAIT_CONTRACT[waitKey]);
  } else if (Array.isArray(covers) && covers.length === 1) {
    pushEntry(__WAIT_CONTRACT[covers[0]]);
  }
  for (const entry of entries) {
    await runWaitEntry(page, ctx, entry);
  }
}

async function executeBackendAssertion(ctx, assertion) {
  if (!assertion || !assertion.api) return;
  const apiRef = parseApiRef(__BACKEND_API_MAP[assertion.api]);
  if (!apiRef) throw new Error('missing api_map entry for assertion.api=' + JSON.stringify(assertion.api) + '; available keys: ' + Object.keys(__BACKEND_API_MAP).join(', '));
  const field = await resolveContractGraphqlField(ctx, 'query', assertion.graphql_field, apiRef.domain, apiRef.entity, assertion.api);
  if (!field) throw new Error('missing GraphQL field for backend assertion ' + JSON.stringify(assertion));
  const timeout = Number(assertion?.timeout) > 0 ? Number(assertion.timeout) : 15000;
  await retryBackendAssertion(timeout, async () => {
    if (assertion.api === 'get') {
      const id = resolveBackendAssertionId(ctx, assertion);
      const payload = await graphqlRequest(ctx, `query ContractGet($id: ID!) { ${field}(id: $id) { ${__BACKEND_SELECTION} } }`, { id });
      if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend get graphql errors: ' + JSON.stringify(payload.errors));
      const record = payload?.data?.[field];
      const actual = readValueAtPath(record, assertion.path || null);
      if (assertion.op === 'exists' && (actual == null || actual === '')) throw new Error('backend get exists assertion failed for ' + String(assertion.path || 'record'));
      if (assertion.op === 'equals' || assertion.op === 'field_equals') {
        const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
        if (String(actual ?? '') !== expected) throw new Error('backend get equals assertion failed: expected ' + expected + ' got ' + String(actual ?? ''));
      }
      applyBindings(ctx, assertion.binds, record);
      refreshDataBindings(ctx);
      return;
    }
    if (assertion.api === 'list') {
      const payload = await graphqlRequest(ctx, `query ContractList { ${field} { results { ${__BACKEND_SELECTION} } count } }`, {});
      if (Array.isArray(payload?.errors) && payload.errors.length > 0) throw new Error('backend list graphql errors: ' + JSON.stringify(payload.errors));
      const results = payload?.data?.[field]?.results || [];
      if (assertion.op === 'exists' && !Array.isArray(results)) throw new Error('backend list exists assertion failed');
      if (assertion.op === 'contains_equals') {
        const expected = resolveTemplateString(ctx, String(assertion.equals || ''));
        const matched = Array.isArray(results)
          ? results.find((row) => String(readValueAtPath(row, assertion.path || null) ?? '') === expected)
          : null;
        if (!matched) throw new Error('backend list contains_equals assertion failed for ' + String(assertion.path || 'record'));
        applyBindings(ctx, assertion.binds, matched);
        refreshDataBindings(ctx);
        return;
      }
      if (assertion.op === 'not_contains') {
        const excluded = resolveTemplateString(ctx, '{{' + String(assertion.excludes_source || '') + '}}');
        const ids = Array.isArray(results) ? results.map((row) => readValueAtPath(row, 'id')) : [];
        if (ids.some((id) => String(id || '') === excluded)) throw new Error('backend list not_contains assertion failed for ' + excluded);
      }
    }
  });
}

async function captureCreatedRecordId(ctx, caseKind, covers) {
  const isCreate = caseKind === 'create' || caseKind === 'crud' || (Array.isArray(covers) && covers.some((c) => { const s = String(c); return s.includes('create') || s === 'form_submit' || s === 'action_create'; }));
  if (!isCreate) return;
  if (ctx.created_record_id) return;
  const listApiRef = parseApiRef(__BACKEND_API_MAP['list']);
  if (!listApiRef) return;
  try {
    const listField = await resolveContractGraphqlField(ctx, 'query', null, listApiRef.domain, listApiRef.entity, 'list');
    if (!listField) return;
    const payload = await graphqlRequest(ctx, `query CaptureCreated { ${listField} { results { id } count } }`, {});
    const rows = Array.isArray(payload?.data?.[listField]?.results) ? payload.data[listField].results : [];
    const allIds = rows.map((r) => r?.id).filter(Boolean);
    if (!ctx.__pre_create_ids) ctx.__pre_create_ids = new Set();
    const existing = new Set([...(ctx.__cleanup_queue || []).map((q) => q.id), ...(ctx.__seed_ids || []), ...[ctx.seed_record_id, ctx.active_record_id].filter(Boolean)]);
    const matched = rows.find((r) => r?.id && !ctx.__pre_create_ids.has(r.id) && !existing.has(r.id));
    if (matched?.id) {
      ctx.created_record_id = matched.id;
      ctx.__cleanup_queue = ctx.__cleanup_queue || [];
      ctx.__cleanup_queue.push({ id: matched.id, domain: listApiRef.domain, entity: listApiRef.entity });
      refreshDataBindings(ctx);
    }
  } catch (e) { if (e && e.message) console.error('captureCreatedRecordId failed:', e.message); }
}

async function runCaseVerification(page, ctx, verificationKey, caseKind, covers) {
  const entries = collectVerificationEntries(verificationKey, caseKind, covers);
  for (const entry of entries) {
    if (!entry) continue;
    for (const ui of Array.isArray(entry.ui) ? entry.ui : []) {
      if (ui?.assert === 'visible' && ui.selector) await expect(locatorFor(page, ui.selector)).toBeVisible({ timeout: 15000 });
      if (ui?.assert === 'text_contains' && ui.selector) await expect(locatorFor(page, ui.selector)).toContainText(resolveTemplateString(ctx, String(ui.value || '')), { timeout: 15000 });
      if (ui?.assert === 'url_contains' && ui.value) await expect(page).toHaveURL(new RegExp(escapeRegex(resolveTemplateString(ctx, String(ui.value)))));
    }
    await executeBackendAssertion(ctx, entry.backend);
  }
}

async function runContractCleanup(ctx) {
  const seedIds = ctx.__seed_ids || new Set();
  const dynamicQueue = Array.isArray(ctx.__cleanup_queue) ? [...ctx.__cleanup_queue].reverse() : [];
  for (const entry of dynamicQueue) {
    if (!entry?.id || !entry?.domain || !entry?.entity) continue;
    if (seedIds.has(entry.id)) continue;
    try {
      const field = await resolveContractGraphqlField(ctx, 'mutation', null, entry.domain, entry.entity, 'destroy');
      if (!field) continue;
      await graphqlRequest(ctx, `mutation DynamicCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id: entry.id });
    } catch (e) { console.error('cleanup failed for id=' + entry.id + ':', e?.message || e); }
  }
  for (const item of Array.isArray(__DATA_CONTRACT.cleanup) ? __DATA_CONTRACT.cleanup : []) {
    if (!item?.api) continue;
    const apiRef = parseApiRef(__BACKEND_API_MAP[item.api]);
    if (!apiRef) continue;
    const id = resolveCleanupSourceValue(ctx, item.source, item.path);
    if (id == null || id === '') {
      if (item.ignore_missing) continue;
      throw new Error('cleanup source value missing for ' + JSON.stringify(item));
    }
    if (seedIds.has(id)) continue;
    const field = await resolveContractGraphqlField(ctx, 'mutation', null, apiRef.domain, apiRef.entity, item.api);
    if (!field) {
      if (item.ignore_missing) continue;
      throw new Error('missing GraphQL mutation field for cleanup ' + JSON.stringify(item));
    }
    const payload = await graphqlRequest(ctx, `mutation ContractCleanup($id: ID!) { ${field}(id: $id) { result { id } errors { message } } }`, { id });
    const errors = payload?.errors || payload?.data?.[field]?.errors || [];
    if (!item.ignore_missing && Array.isArray(errors) && errors.length > 0) {
      throw new Error('cleanup mutation failed for ' + String(field));
    }
  }
}

async function waitForLiveViewReady(page, timeout) {
  const root = page.locator('[data-phx-main]');
  await root.waitFor({ state: 'attached', timeout });
  await page.waitForFunction(() => {
    const node = document.querySelector('[data-phx-main]');
    if (!node) return false;
    const cls = node.getAttribute('class') || '';
    return cls.includes('phx-connected') || !cls.includes('phx-loading');
  }, { timeout });
}

function rememberFormValue(ctx, selector, value) {
  const patterns = [
    /\[name=['"]([^'"]+)['"]\]/,
    /#form_([a-zA-Z0-9_]+)/,
    /#(?:[a-zA-Z0-9_]+)_fcl_form_([a-zA-Z0-9_]+)/,
    /#(?:[a-zA-Z0-9_]+)_wizard_step[12]_([a-zA-Z0-9_]+)/,
  ];
  for (const re of patterns) {
    const m = selector.match(re);
    if (m) {
      ctx.form[m[1]] = value;
      refreshDataBindings(ctx);
      return;
    }
  }
}

async function syncRouteContext(page, ctx) {
  const current = new URL(page.url());
  let id = current.searchParams.get('id');
  if (!id) {
    const parts = current.pathname.split('/').filter(Boolean);
    const last = parts[parts.length - 1] || '';
    if (last && last !== 'new' && /^[0-9a-fA-F-]{8,}$/.test(last)) id = last;
  }
  ctx.route = ctx.route || {};
  if (id) {
    ctx.route.id = id;
  } else {
    delete ctx.route.id;
  }
  refreshDataBindings(ctx);
}

function resolveContractUrl(ctx) {
  let path = resolveTemplateString(ctx, "/pages/travel/travel_order/:id");
  if (path.includes(':id')) {
    const id = ctx.active_record_id || ctx.route_record_id || ctx.seed_record_id || ctx.route?.id || '';
    if (!id) throw new Error('detail route requires id but no route id is available');
    path = path.replace(':id', id);
  }
  return new URL(path, "http://localhost:4100/").toString();
}

async function ensureSeedRecord(page, __ctx) {
  await ensureContractSetup(page, __ctx);
  await syncRouteContext(page, __ctx);
  const seedId = __ctx.active_record_id || __ctx.route_record_id || __ctx.seed_record_id || __ctx.created_record_id || __ctx.route?.id;
  if (seedId) return;
  throw new Error('detail route requires seed record id from data_contract.setup');
}

test.describe("travel_order_detail", () => {
  test('E2E flow', async ({ page }) => {
    test.setTimeout(810000);
    const __memo = new Map();
    const __ctx = { form: {}, route: {}, clicked_row: null, active_record_id: null, seed_record_id: null, created_record_id: null, route_record_id: null, __run_id: String(Date.now()) + '_' + Math.random().toString(36).slice(2, 8), __cleanup_queue: [], __seed_ids: new Set() };
    try {
      await ensureContractSetup(page, __ctx);
      await test.step("页面加载 + 结构可见", async () => {
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
        await runCaseWait(page, __ctx, "load", []);
        await captureCreatedRecordId(__ctx, "load", []);
        await runCaseVerification(page, __ctx, "load", "load", []);
      });
      await test.step("编辑模式切换", async () => {
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#edit_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      await expect(page.locator(`#travel_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#cancel_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      await expect(page.locator(`#travel_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).not.toBeVisible({ timeout: 15000 });
        await runCaseWait(page, __ctx, null, ["toggle_edit","cancel_edit"]);
        await captureCreatedRecordId(__ctx, "flow", ["toggle_edit","cancel_edit"]);
        await runCaseVerification(page, __ctx, "toggle_edit", "flow", ["toggle_edit","cancel_edit"]);
      });
      await test.step("CRUD：编辑记录", async () => {
        await snapshotPreCreateIds(__ctx);
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#edit_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      await expect(page.locator(`#travel_order_edit_form, #main_form, form[phx-submit="form_submit"]`).first()).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_form_ticket_passenger_infos, [name='ticket_passenger_infos']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "{\"updated\":true}");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["ticket_passenger_infos"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#travel_order_form_seat_selection_snapshot, [name='seat_selection_snapshot']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "{\"updated\":true}");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["seat_selection_snapshot"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#travel_order_form_contact_phone, [name='contact_phone']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_contact_phone");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["contact_phone"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#travel_order_form_contact_name, [name='contact_name']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "UPDATED_{{__run_id}}_contact_name");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["contact_name"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#travel_order_form_traveler_count, [name='traveler_count']`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const resolvedValue = resolveTemplateString(__ctx, "2");
        await loc.fill(resolvedValue, { timeout: 15000 });
        __ctx.form["traveler_count"] = resolvedValue; refreshDataBindings(__ctx);
      }
      {
        const loc = page.locator(`#travel_order_edit_form button[type="submit"], #travel_order_edit_form [phx-click="form_submit"]`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          refreshDataBindings(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "form_submit", ["toggle_edit","form_change","form_submit"]);
        await captureCreatedRecordId(__ctx, "crud", ["toggle_edit","form_change","form_submit"]);
        await runCaseVerification(page, __ctx, "update", "crud", ["toggle_edit","form_change","form_submit"]);
      });
      await test.step("状态转换：draft → quoted（confirm_quote）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_confirm_quote}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_confirm_quote`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_confirm_quote"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_confirm_quote"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_confirm_quote", ["action_confirm_quote"]);
        await captureCreatedRecordId(__ctx, "state", ["action_confirm_quote"]);
        await runCaseVerification(page, __ctx, "action_confirm_quote", "state", ["action_confirm_quote"]);
      });
      await test.step("状态转换：quoted → submitted（submit_order）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_submit_order}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_submit_order`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_submit_order"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_submit_order"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_submit_order", ["action_submit_order"]);
        await captureCreatedRecordId(__ctx, "state", ["action_submit_order"]);
        await runCaseVerification(page, __ctx, "action_submit_order", "state", ["action_submit_order"]);
      });
      await test.step("状态转换：quoted → submitted（submit_waitlist）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_submit_waitlist}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_submit_waitlist`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_submit_waitlist"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_submit_waitlist"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_submit_waitlist", ["action_submit_waitlist"]);
        await captureCreatedRecordId(__ctx, "state", ["action_submit_waitlist"]);
        await runCaseVerification(page, __ctx, "action_submit_waitlist", "state", ["action_submit_waitlist"]);
      });
      await test.step("状态转换：submitted → booking_pending（mark_payment_succeeded）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_mark_payment_succeeded}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_mark_payment_succeeded`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_mark_payment_succeeded"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_mark_payment_succeeded"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_mark_payment_succeeded", ["action_mark_payment_succeeded"]);
        await captureCreatedRecordId(__ctx, "state", ["action_mark_payment_succeeded"]);
        await runCaseVerification(page, __ctx, "action_mark_payment_succeeded", "state", ["action_mark_payment_succeeded"]);
      });
      await test.step("状态转换：submitted → failed（mark_order_failed）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_mark_order_failed}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_mark_order_failed`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_mark_order_failed"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_mark_order_failed"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_mark_order_failed", ["action_mark_order_failed"]);
        await captureCreatedRecordId(__ctx, "state", ["action_mark_order_failed"]);
        await runCaseVerification(page, __ctx, "action_mark_order_failed", "state", ["action_mark_order_failed"]);
      });
      await test.step("状态转换：booking_pending → booked（mark_booked）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_mark_booked}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_mark_booked`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_mark_booked"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_mark_booked"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_mark_booked", ["action_mark_booked"]);
        await captureCreatedRecordId(__ctx, "state", ["action_mark_booked"]);
        await runCaseVerification(page, __ctx, "action_mark_booked", "state", ["action_mark_booked"]);
      });
      await test.step("状态转换：booking_pending → booked（fulfill_waitlist）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_fulfill_waitlist}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_fulfill_waitlist`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_fulfill_waitlist"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_fulfill_waitlist"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_fulfill_waitlist", ["action_fulfill_waitlist"]);
        await captureCreatedRecordId(__ctx, "state", ["action_fulfill_waitlist"]);
        await runCaseVerification(page, __ctx, "action_fulfill_waitlist", "state", ["action_fulfill_waitlist"]);
      });
      await test.step("状态转换：booking_pending → cancelled（cancel_waitlist）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_cancel_waitlist}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_cancel_waitlist`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_cancel_waitlist"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_cancel_waitlist"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_cancel_waitlist", ["action_cancel_waitlist"]);
        await captureCreatedRecordId(__ctx, "state", ["action_cancel_waitlist"]);
        await runCaseVerification(page, __ctx, "action_cancel_waitlist", "state", ["action_cancel_waitlist"]);
      });
      await test.step("状态转换：booked → completed（mark_completed）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_mark_completed}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_mark_completed`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_mark_completed"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_mark_completed"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_mark_completed", ["action_mark_completed"]);
        await captureCreatedRecordId(__ctx, "state", ["action_mark_completed"]);
        await runCaseVerification(page, __ctx, "action_mark_completed", "state", ["action_mark_completed"]);
      });
      await test.step("状态转换：booked → cancel_pending（request_cancel）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_request_cancel}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_request_cancel`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_request_cancel"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_request_cancel"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_request_cancel", ["action_request_cancel"]);
        await captureCreatedRecordId(__ctx, "state", ["action_request_cancel"]);
        await runCaseVerification(page, __ctx, "action_request_cancel", "state", ["action_request_cancel"]);
      });
      await test.step("状态转换：cancel_pending → cancelled（execute_cancel）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_execute_cancel}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_execute_cancel`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_execute_cancel"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_execute_cancel"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_execute_cancel", ["action_execute_cancel"]);
        await captureCreatedRecordId(__ctx, "state", ["action_execute_cancel"]);
        await runCaseVerification(page, __ctx, "action_execute_cancel", "state", ["action_execute_cancel"]);
      });
      await test.step("状态转换：cancel_pending → booked（cancel_cancel_request）", async () => {
      {
        const targetValue = resolveTemplateString(__ctx, "/pages/travel/travel_order/{{state_action_record_id_cancel_cancel_request}}");
        const target = /^https?:\/\//.test(targetValue)
          ? targetValue
          : new URL(targetValue, "http://localhost:4100/").toString();
        await page.goto(target);
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
      await expect(page.locator(`#travel_order_detail`)).toBeVisible({ timeout: 15000 });
      {
        const loc = page.locator(`#travel_order_action_cancel_cancel_request`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_cancel_cancel_request"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_cancel_cancel_request"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_cancel_cancel_request", ["action_cancel_cancel_request"]);
        await captureCreatedRecordId(__ctx, "state", ["action_cancel_cancel_request"]);
        await runCaseVerification(page, __ctx, "action_cancel_cancel_request", "state", ["action_cancel_cancel_request"]);
      });
      await test.step("动作：request_change", async () => {
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#travel_order_action_request_change`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_request_change"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_request_change"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_request_change", ["action_request_change"]);
        await captureCreatedRecordId(__ctx, "custom", ["action_request_change"]);
        await runCaseVerification(page, __ctx, null, "custom", ["action_request_change"]);
      });
      await test.step("动作：confirm_change", async () => {
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#travel_order_action_confirm_change`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_confirm_change"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_confirm_change"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
        await runCaseWait(page, __ctx, "action_confirm_change", ["action_confirm_change"]);
        await captureCreatedRecordId(__ctx, "custom", ["action_confirm_change"]);
        await runCaseVerification(page, __ctx, null, "custom", ["action_confirm_change"]);
      });
      await test.step("动作：删除", async () => {
        await snapshotPreCreateIds(__ctx);
        if (__ctx.created_record_id) { __ctx.active_record_id = __ctx.created_record_id; }
        await ensureSeedRecord(page, __ctx);
        await page.goto(resolveContractUrl(__ctx));
        await syncRouteContext(page, __ctx);
        await waitForLiveViewReady(page, 15000);
      {
        const loc = page.locator(`#delete_btn`).first();
        await loc.waitFor({ state: 'visible', timeout: 15000 });
        const clickedId = await loc.getAttribute('phx-value-id') || await loc.getAttribute('data-id');
        const confirmText = await loc.getAttribute('data-confirm');
        await loc.scrollIntoViewIfNeeded();
        if (confirmText) {
          const dialogPromise = page.waitForEvent('dialog', { timeout: 15000 })
            .then(async (dialog) => { await dialog.accept(); return dialog; })
            .catch(() => null);
          await loc.click({ timeout: 15000, noWaitAfter: true });
          await dialogPromise;
        } else {
          await loc.click({ timeout: 15000 });
        }
        if (clickedId) {
          __ctx.clicked_row = { ...( __ctx.clicked_row || {}), id: clickedId };
          __ctx["state_action_record_id_destroy"] = clickedId;
          refreshDataBindings(__ctx);
        }
        if (!clickedId) {
          __ctx["state_action_record_id_destroy"] = defaultRecordId(__ctx);
        }
        await waitForLiveViewReady(page, 15000);
        await syncRouteContext(page, __ctx);
      }
      {
        const expectedUrl = resolveTemplateString(__ctx, "/pages/travel/travel_order");
      try {
        await page.waitForFunction((v) => window.location.href.includes(v), expectedUrl, { timeout: 15000 });
      } catch (e) {
        await page.waitForURL((url) => url.toString().includes(expectedUrl), { timeout: 15000 });
      }
      }
      await waitForLiveViewReady(page, 15000);
      await syncRouteContext(page, __ctx);
        await runCaseWait(page, __ctx, "destroy", ["action_destroy"]);
        await captureCreatedRecordId(__ctx, "crud", ["action_destroy"]);
        await runCaseVerification(page, __ctx, "destroy", "crud", ["action_destroy"]);
      });
    } finally {
      await runContractCleanup(__ctx);
    }
  });
});
