[SCENARIO: BDD-SALES_CUSTOMER-SEED-sales_customer_action_customer_search_read] TITLE: SALES_CUSTOMER contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="sales_customer_action_customer_search_read" module="SALES_CUSTOMER"
WHEN when_execute_seed_contract module="SALES_CUSTOMER"
THEN then_seed_contract_should_hold module="SALES_CUSTOMER"
