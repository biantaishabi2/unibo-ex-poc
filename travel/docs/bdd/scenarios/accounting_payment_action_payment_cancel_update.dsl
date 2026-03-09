[SCENARIO: BDD-ACCOUNTING_PAYMENT-SEED-accounting_payment_action_payment_cancel_update] TITLE: ACCOUNTING_PAYMENT contract seed scenario TAGS: seed all
GIVEN given_seed_context id="accounting_payment_action_payment_cancel_update" module="ACCOUNTING_PAYMENT"
WHEN when_execute_seed_contract module="ACCOUNTING_PAYMENT"
THEN then_seed_contract_should_hold module="ACCOUNTING_PAYMENT"
