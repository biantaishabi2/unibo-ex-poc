[SCENARIO: BDD-ORDER_ORDER_HEADER-SEED-order_order_header_action_order_header_read_read] TITLE: ORDER_ORDER_HEADER contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="order_order_header_action_order_header_read_read" module="ORDER_ORDER_HEADER"
WHEN when_execute_seed_contract module="ORDER_ORDER_HEADER"
THEN then_seed_contract_should_hold module="ORDER_ORDER_HEADER"
