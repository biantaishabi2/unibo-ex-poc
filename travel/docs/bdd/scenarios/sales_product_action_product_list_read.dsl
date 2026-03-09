[SCENARIO: BDD-SALES_PRODUCT-SEED-sales_product_action_product_list_read] TITLE: SALES_PRODUCT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="sales_product_action_product_list_read" module="SALES_PRODUCT"
WHEN when_execute_seed_contract module="SALES_PRODUCT"
THEN then_seed_contract_should_hold module="SALES_PRODUCT"
