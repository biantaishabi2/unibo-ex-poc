[SCENARIO: BDD-ORDER_QUOTE-SEED-order_quote_action_quote_create_create] TITLE: ORDER_QUOTE contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="order_quote_action_quote_create_create" module="ORDER_QUOTE"
WHEN when_execute_seed_contract module="ORDER_QUOTE"
THEN then_seed_contract_should_hold module="ORDER_QUOTE"
