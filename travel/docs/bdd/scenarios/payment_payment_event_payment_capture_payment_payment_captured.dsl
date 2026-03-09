[SCENARIO: BDD-PAYMENT_PAYMENT-SEED-payment_payment_event_payment_capture_payment_payment_captured] TITLE: PAYMENT_PAYMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="payment_payment_event_payment_capture_payment_payment_captured" module="PAYMENT_PAYMENT"
WHEN when_execute_seed_contract module="PAYMENT_PAYMENT"
THEN then_seed_contract_should_hold module="PAYMENT_PAYMENT"
