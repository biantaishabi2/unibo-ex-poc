[SCENARIO: BDD-PURCHASING_PRODUCT-SEED-purchasing_product_action_product_compute_read] TITLE: PURCHASING_PRODUCT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="purchasing_product_action_product_compute_read" module="PURCHASING_PRODUCT"
WHEN when_execute_seed_contract module="PURCHASING_PRODUCT"
THEN then_seed_contract_should_hold module="PURCHASING_PRODUCT"
