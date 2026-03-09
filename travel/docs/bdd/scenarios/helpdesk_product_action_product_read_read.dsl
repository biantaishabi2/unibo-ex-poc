[SCENARIO: BDD-HELPDESK_PRODUCT-SEED-helpdesk_product_action_product_read_read] TITLE: HELPDESK_PRODUCT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="helpdesk_product_action_product_read_read" module="HELPDESK_PRODUCT"
WHEN when_execute_seed_contract module="HELPDESK_PRODUCT"
THEN then_seed_contract_should_hold module="HELPDESK_PRODUCT"
