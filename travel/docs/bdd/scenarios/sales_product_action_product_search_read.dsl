[SCENARIO: BDD-SALES_PRODUCT-SEED-sales_product_action_product_search_read] TITLE: SALES_PRODUCT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="sales_product_action_product_search_read" module="SALES_PRODUCT"
WHEN when_execute_seed_contract module="SALES_PRODUCT"
THEN then_seed_contract_should_hold module="SALES_PRODUCT"
