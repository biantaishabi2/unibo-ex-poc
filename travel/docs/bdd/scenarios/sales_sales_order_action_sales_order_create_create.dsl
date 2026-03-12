[SCENARIO: BDD-SALES_SALES_ORDER-SEED-sales_sales_order_action_sales_order_create_create] TITLE: SALES_SALES_ORDER contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="sales_sales_order_action_sales_order_create_create" module="SALES_SALES_ORDER"
WHEN when_execute_seed_contract module="SALES_SALES_ORDER"
THEN then_seed_contract_should_hold module="SALES_SALES_ORDER"
