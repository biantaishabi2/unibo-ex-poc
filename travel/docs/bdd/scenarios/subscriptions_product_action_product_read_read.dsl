[SCENARIO: BDD-SUBSCRIPTIONS_PRODUCT-SEED-subscriptions_product_action_product_read_read] TITLE: SUBSCRIPTIONS_PRODUCT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="subscriptions_product_action_product_read_read" module="SUBSCRIPTIONS_PRODUCT"
WHEN when_execute_seed_contract module="SUBSCRIPTIONS_PRODUCT"
THEN then_seed_contract_should_hold module="SUBSCRIPTIONS_PRODUCT"
