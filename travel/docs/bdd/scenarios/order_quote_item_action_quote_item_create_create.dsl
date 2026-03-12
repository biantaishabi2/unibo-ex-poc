[SCENARIO: BDD-ORDER_QUOTE_ITEM-SEED-order_quote_item_action_quote_item_create_create] TITLE: ORDER_QUOTE_ITEM contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="order_quote_item_action_quote_item_create_create" module="ORDER_QUOTE_ITEM"
WHEN when_execute_seed_contract module="ORDER_QUOTE_ITEM"
THEN then_seed_contract_should_hold module="ORDER_QUOTE_ITEM"
