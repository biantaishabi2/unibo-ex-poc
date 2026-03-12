[SCENARIO: BDD-PAYMENT_PAYMENT-SEED-payment_payment_action_payment_refund_update] TITLE: PAYMENT_PAYMENT contract seed scenario TAGS: seed action_contract
GIVEN given_seed_context id="payment_payment_action_payment_refund_update" module="PAYMENT_PAYMENT"
WHEN when_execute_seed_contract module="PAYMENT_PAYMENT"
THEN then_seed_contract_should_hold module="PAYMENT_PAYMENT"
