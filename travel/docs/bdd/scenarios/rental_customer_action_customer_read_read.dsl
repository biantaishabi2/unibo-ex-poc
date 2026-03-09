[SCENARIO: BDD-RENTAL_CUSTOMER-SEED-rental_customer_action_customer_read_read] TITLE: RENTAL_CUSTOMER contract seed scenario TAGS: seed all
GIVEN given_seed_context id="rental_customer_action_customer_read_read" module="RENTAL_CUSTOMER"
WHEN when_execute_seed_contract module="RENTAL_CUSTOMER"
THEN then_seed_contract_should_hold module="RENTAL_CUSTOMER"
