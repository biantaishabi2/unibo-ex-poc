[SCENARIO: BDD-PAYMENT_PAYMENT_TYPE-SEED-payment_payment_type_action_payment_type_read_read] TITLE: PAYMENT_PAYMENT_TYPE contract seed scenario TAGS: seed all
GIVEN given_seed_context id="payment_payment_type_action_payment_type_read_read" module="PAYMENT_PAYMENT_TYPE"
WHEN when_execute_seed_contract module="PAYMENT_PAYMENT_TYPE"
THEN then_seed_contract_should_hold module="PAYMENT_PAYMENT_TYPE"
