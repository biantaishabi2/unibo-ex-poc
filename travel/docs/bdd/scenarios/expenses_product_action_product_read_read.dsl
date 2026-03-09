[SCENARIO: BDD-EXPENSES_PRODUCT-SEED-expenses_product_action_product_read_read] TITLE: EXPENSES_PRODUCT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="expenses_product_action_product_read_read" module="EXPENSES_PRODUCT"
WHEN when_execute_seed_contract module="EXPENSES_PRODUCT"
THEN then_seed_contract_should_hold module="EXPENSES_PRODUCT"
