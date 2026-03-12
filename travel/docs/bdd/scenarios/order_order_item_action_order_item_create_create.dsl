[SCENARIO: BDD-ORDER_ORDER_ITEM-SEED-order_order_item_action_order_item_create_create] TITLE: ORDER_ORDER_ITEM contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="order_order_item_action_order_item_create_create" module="ORDER_ORDER_ITEM"
WHEN when_execute_seed_contract module="ORDER_ORDER_ITEM"
THEN then_seed_contract_should_hold module="ORDER_ORDER_ITEM"
