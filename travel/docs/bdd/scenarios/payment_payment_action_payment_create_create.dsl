[SCENARIO: BDD-PAYMENT_PAYMENT-SEED-payment_payment_action_payment_create_create] TITLE: PAYMENT_PAYMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="payment_payment_action_payment_create_create" module="PAYMENT_PAYMENT"
WHEN when_execute_seed_contract module="PAYMENT_PAYMENT"
THEN then_seed_contract_should_hold module="PAYMENT_PAYMENT"
